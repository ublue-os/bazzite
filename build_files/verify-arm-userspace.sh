#!/usr/bin/bash

set -euo pipefail

if [[ "$(uname -m)" != "aarch64" ]]; then
    echo "ARM userspace verification only applies to aarch64 images" >&2
    exit 1
fi

foreign_rpms="$(
    rpm -qa --qf '%{NAME}\t%{ARCH}\n' |
        awk '$2 != "aarch64" && $2 != "noarch" && !($1 == "gpg-pubkey" && $2 == "(none)")'
)"
if [[ -n "${foreign_rpms}" ]]; then
    echo "Found non-native RPM payloads in the ARM image:" >&2
    printf '%s\n' "${foreign_rpms}" >&2
    exit 1
fi

scan_roots=(
    /opt
    /usr/bin
    /usr/lib
    /usr/lib64
    /usr/libexec
    /usr/local/bin
    /usr/local/lib
    /usr/local/lib64
    /usr/local/libexec
    /usr/local/sbin
    /usr/sbin
)

existing_roots=()
for root in "${scan_roots[@]}"; do
    if [[ -d "${root}" ]]; then
        existing_roots+=("${root}")
    fi
done

if [[ ${#existing_roots[@]} -eq 0 ]]; then
    echo "No userspace roots found to scan; skipping binary architecture audit."
    exit 0
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is required for the userspace binary architecture audit" >&2
    exit 1
fi

python3 - "${existing_roots[@]}" <<'PY'
import os
import stat
import sys

roots = sys.argv[1:]
exclude_prefixes = (
    "/usr/lib/fex-emu-overlay",
    "/usr/lib64/fex-emu-overlay",
    "/usr/share/fex-emu",
)
elf_x86 = {
    3: "ELF i386",
    62: "ELF x86_64",
}
pe_x86 = {
    0x14C: "PE i386",
    0x8664: "PE x86_64",
}
bad = []
scanned = 0


def is_candidate(path: str, mode: int) -> bool:
    name = os.path.basename(path).lower()
    return bool(mode & 0o111) or ".so" in name or name.endswith((".dll", ".drv", ".exe", ".ocx"))


def is_excluded(path: str) -> bool:
    return any(path.startswith(prefix) for prefix in exclude_prefixes)


for root in roots:
    for dirpath, dirnames, filenames in os.walk(root):
        real_dir = os.path.realpath(dirpath)
        if is_excluded(real_dir):
            dirnames[:] = []
            continue

        kept = []
        for dirname in dirnames:
            child = os.path.realpath(os.path.join(real_dir, dirname))
            if not is_excluded(child):
                kept.append(dirname)
        dirnames[:] = kept

        for filename in filenames:
            path = os.path.join(real_dir, filename)
            real_path = os.path.realpath(path)
            if is_excluded(real_path):
                continue
            try:
                st = os.stat(real_path, follow_symlinks=True)
            except OSError:
                continue
            if not stat.S_ISREG(st.st_mode):
                continue
            if not is_candidate(real_path, st.st_mode):
                continue

            scanned += 1
            try:
                with open(real_path, "rb") as handle:
                    head = handle.read(0x100)
                    if head.startswith(b"\x7fELF") and len(head) >= 20:
                        machine = int.from_bytes(head[18:20], "little")
                        if machine in elf_x86:
                            bad.append((elf_x86[machine], path))
                    elif head.startswith(b"MZ") and len(head) >= 0x40:
                        pe_offset = int.from_bytes(head[0x3C:0x40], "little")
                        if pe_offset > 1024 * 1024:
                            continue
                        handle.seek(pe_offset)
                        sig = handle.read(6)
                        if len(sig) >= 6 and sig[:4] == b"PE\0\0":
                            machine = int.from_bytes(sig[4:6], "little")
                            if machine in pe_x86:
                                bad.append((pe_x86[machine], path))
            except OSError:
                continue

print(f"Scanned {scanned} candidate userspace binaries and libraries.")
if bad:
    print("Unexpected x86 payloads detected outside emulation roots:", file=sys.stderr)
    for kind, path in bad[:200]:
        print(f"{kind}\t{path}", file=sys.stderr)
    sys.exit(1)
PY
