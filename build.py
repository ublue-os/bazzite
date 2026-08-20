#!/usr/bin/env python3
"""build.py -- build orchestrator.

Quick start:

    ./build.py doctor              # check your machine is set up to build
    ./build.py images              # list valid --image values
    ./build.py build                       # build "bazzite" (the default)
    ./build.py build --image bazzite-deck  # build a specific variant
    ./build.py shell                       # build if needed, then drop into it
    ./build.py build --image bazzite-deck-nvidia --dry-run   # show, don't run

CI usage:

    ./build.py matrix              # GitHub Actions matrix JSON (via fromJson)
    ./build.py resolve --image X   # build args + labels + tags, as JSON
    ./build.py build --image X --rechunk --sbom --sign --push

Every subcommand accepts -v/--verbose and -q/--quiet. Diagnostic output goes
to stderr; JSON/data output goes to stdout, so `./build.py matrix | jq` and
`VALUE=$(./build.py resolve --image X | jq -r .version_tag)` both work
cleanly even with logging turned up.
"""

from __future__ import annotations

import argparse
import contextlib
import dataclasses
import json
import logging
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import ClassVar

log = logging.getLogger("build")

REPO_ROOT = Path(__file__).resolve().parent
PULL_REGISTRY = "ghcr.io/ublue-os"
IMAGE_VENDOR_DEFAULT = "ublue-os"

# ---------------------------------------------------------------------------
# Each row is written out explicitly rather than derived from substring
# matching on the image name. The old derivation (build.yml:104-160) had
# subtle rules -- e.g. nvidia_flavor was "nvidia-open" if the name *ended*
# with "nvidia-open" OR *contained* "-deck-nvidia", else "nvidia-lts" -- and
# an explicit table is the only version of that logic that's reviewable at a
# glance. test_build.py asserts these rows match what the bash used to
# derive for all 10 images.
# ---------------------------------------------------------------------------

DEFAULTS = {
    "fedora_version": 44,
    "kernel_flavor": "ogc",
    "kernel_version": "7.2.0-ogc3.1.fc44",
    "base_image_flavor": "main",
    "arch": "x86_64",
}

IMAGES: dict[str, dict] = {
    "bazzite": {
        "base_image_name": "kinoite",
        "container_target": "bazzite",
        "nvidia_base": "bazzite",
        "nvidia_flavor": "nvidia-lts",
        "install_nvidia": False,
    },
    "bazzite-gnome": {
        "base_image_name": "silverblue",
        "container_target": "bazzite",
        "nvidia_base": "bazzite",
        "nvidia_flavor": "nvidia-lts",
        "install_nvidia": False,
    },
    "bazzite-deck": {
        "base_image_name": "kinoite",
        "container_target": "bazzite-deck",
        "nvidia_base": "bazzite-deck",
        "nvidia_flavor": "nvidia-lts",
        "install_nvidia": False,
    },
    "bazzite-deck-gnome": {
        "base_image_name": "silverblue",
        "container_target": "bazzite-deck",
        "nvidia_base": "bazzite-deck",
        "nvidia_flavor": "nvidia-lts",
        "install_nvidia": False,
    },
    "bazzite-deck-nvidia": {
        "base_image_name": "kinoite",
        "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite-deck",
        "nvidia_flavor": "nvidia-open",
        "install_nvidia": True,
    },
    "bazzite-deck-nvidia-gnome": {
        "base_image_name": "silverblue",
        "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite-deck",
        "nvidia_flavor": "nvidia-open",
        "install_nvidia": True,
    },
    "bazzite-nvidia": {
        "base_image_name": "kinoite",
        "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite",
        "nvidia_flavor": "nvidia-lts",
        "install_nvidia": True,
        "kernel_flavor": "ogc-lts",
        "kernel_version": "6.18.44-ogc1.1.fc44",
    },
    "bazzite-gnome-nvidia": {
        "base_image_name": "silverblue",
        "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite",
        "nvidia_flavor": "nvidia-lts",
        "install_nvidia": True,
        "kernel_flavor": "ogc-lts",
        "kernel_version": "6.18.44-ogc1.1.fc44",
    },
    "bazzite-nvidia-open": {
        "base_image_name": "kinoite",
        "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite",
        "nvidia_flavor": "nvidia-open",
        "install_nvidia": True,
    },
    "bazzite-gnome-nvidia-open": {
        "base_image_name": "silverblue",
        "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite",
        "nvidia_flavor": "nvidia-open",
        "install_nvidia": True,
    },
}

DEFAULT_IMAGE = "bazzite"

IMAGE_LABELS = {
    "io.artifacthub.package.logo-url": "https://raw.githubusercontent.com/ublue-os/bazzite/main/repo_content/logo.png",
    "io.artifacthub.package.readme-url": "https://raw.githubusercontent.com/ublue-os/bazzite/refs/heads/main/README.md",
    "org.opencontainers.image.description": (
        "Bazzite is a custom image that brings the best of Linux gaming to "
        "all of your devices - including your favorite handheld."
    ),
    "org.opencontainers.image.licenses": "Apache-2.0",
    "org.opencontainers.image.source": "https://bazzite.gg",
    "org.opencontainers.image.title": "Bazzite",
    "org.opencontainers.image.vendor": "Universal Blue",
    "org.opencontainers.image.url": "https://bazzite.gg",
}


# ---------------------------------------------------------------------------
# Logging
#
# Logging goes to stderr, data goes to stdout. `matrix`, `images`,
# and `resolve` print JSON that CI consumes via fromJson/$GITHUB_OUTPUT and
# that contributors pipe into jq -- if a log line ever lands on stdout,
# $(./build.py matrix) breaks in a way that's annoying to track down.
# ---------------------------------------------------------------------------


class GitHubActionsFormatter(logging.Formatter):
    """Maps log levels onto GitHub Actions workflow commands.

    DEBUG becomes ::debug::, which Actions hides unless step debugging is
    enabled, so verbose (-v) logging is free in CI. Multi-line messages have
    their newlines escaped to %0A -- GitHub truncates annotation payloads at
    the first literal newline otherwise.
    """

    _COMMANDS: ClassVar[dict[int, str]] = {
        logging.DEBUG: "debug",
        logging.WARNING: "warning",
        logging.ERROR: "error",
        logging.CRITICAL: "error",
    }

    def format(self, record: logging.LogRecord) -> str:
        message = record.getMessage()
        command = self._COMMANDS.get(record.levelno)
        if command is None:
            return message
        escaped = message.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")
        return f"::{command}::{escaped}"


class PlainFormatter(logging.Formatter):
    """levelname: message, with ANSI color only on a real terminal."""

    _COLORS: ClassVar[dict[int, str]] = {
        logging.DEBUG: "\033[2m",
        logging.WARNING: "\033[33m",
        logging.ERROR: "\033[31m",
        logging.CRITICAL: "\033[31m",
    }
    _RESET = "\033[0m"

    def __init__(self, color: bool) -> None:
        super().__init__()
        self.color = color

    def format(self, record: logging.LogRecord) -> str:
        message = record.getMessage()
        if record.levelno <= logging.INFO:
            return message
        prefix = f"{record.levelname}: "
        if self.color:
            color = self._COLORS.get(record.levelno, "")
            return f"{color}{prefix}{message}{self._RESET}"
        return f"{prefix}{message}"


def setup_logging(verbosity: int) -> None:
    level = logging.INFO
    if verbosity > 0:
        level = logging.DEBUG
    elif verbosity < 0:
        level = logging.WARNING

    handler = logging.StreamHandler(sys.stderr)
    if os.environ.get("GITHUB_ACTIONS") == "true":
        handler.setFormatter(GitHubActionsFormatter())
    else:
        handler.setFormatter(PlainFormatter(color=sys.stderr.isatty()))

    root = logging.getLogger("build")
    root.setLevel(level)
    root.handlers.clear()
    root.addHandler(handler)


_group_depth = 0


@contextlib.contextmanager
def group(title: str):
    """::group::/::endgroup:: in Actions, a plain heading locally.

    Actions doesn't support nested groups, so only the outermost group emits
    markers -- nested calls just log a heading instead of producing a
    broken fold.
    """
    global _group_depth
    in_actions = os.environ.get("GITHUB_ACTIONS") == "true"
    is_outermost = _group_depth == 0
    _group_depth += 1
    try:
        if in_actions and is_outermost:
            print(f"::group::{title}", file=sys.stderr)
        else:
            log.info("=== %s ===", title)
        yield
    finally:
        _group_depth -= 1
        if in_actions and is_outermost:
            print("::endgroup::", file=sys.stderr)


# ---------------------------------------------------------------------------
# Subprocess runner
# ---------------------------------------------------------------------------


class CommandError(RuntimeError):
    pass


def run(
    cmd: list[str],
    *,
    dry_run: bool = False,
    capture: bool = False,
    check: bool = True,
    retries: int = 1,
    retry_wait: float = 5.0,
    env: dict | None = None,
) -> subprocess.CompletedProcess:
    """Run a command. Inherits stdout/stderr unless capture=True.

    Output is inherited rather than captured-and-relogged so that tools like
    buildah and dnf5 render their own progress natively instead of arriving
    line-prefixed and mangled. Only commands whose output is parsed
    (skopeo inspect, skopeo list-tags) should pass capture=True, and those
    are logged at DEBUG rather than INFO.
    """
    printable = " ".join(cmd)
    log.info("+ %s", printable)
    if dry_run:
        return subprocess.CompletedProcess(cmd, 0, stdout="", stderr="")

    run_env = {**os.environ, **env} if env else None
    last_exc: Exception | None = None
    for attempt in range(1, retries + 1):
        try:
            result = subprocess.run(
                cmd,
                check=check,
                capture_output=capture,
                text=capture,
                env=run_env,
            )
            if capture:
                log.debug("output: %s", result.stdout)
            return result
        except subprocess.CalledProcessError as exc:
            last_exc = exc
            if attempt < retries:
                log.warning(
                    "command failed (attempt %d/%d), retrying in %ss: %s",
                    attempt, retries, retry_wait, printable,
                )
                time.sleep(retry_wait)
    assert last_exc is not None
    raise CommandError(str(last_exc)) from last_exc

@dataclasses.dataclass
class Variant:
    image: str
    base_image_name: str
    base_image_flavor: str
    container_target: str
    nvidia_base: str
    nvidia_flavor: str
    install_nvidia: bool
    fedora_version: int
    kernel_flavor: str
    kernel_version: str
    arch: str

    @property
    def base_image(self) -> str:
        return f"{PULL_REGISTRY}/{self.base_image_name}-{self.base_image_flavor}:{self.fedora_version}"

    @property
    def akmods_tag(self) -> str:
        return f"{self.kernel_flavor}-{self.fedora_version}-{self.kernel_version}"

    @property
    def akmods_nvidia_tag(self) -> str | None:
        if not self.install_nvidia:
            return None
        return f"{self.kernel_flavor}-{self.fedora_version}-{self.kernel_version}"


def get_variant(image: str) -> Variant:
    if image not in IMAGES:
        valid = ", ".join(sorted(IMAGES))
        raise ValueError(f"unknown image {image!r}. Valid images: {valid}")
    fields = {**DEFAULTS, **IMAGES[image]}
    return Variant(image=image, **fields)


def build_args(
    variant: Variant,
    *,
    image_vendor: str = IMAGE_VENDOR_DEFAULT,
    image_branch: str = "stable",
    sha_head_short: str = "",
    version_tag: str = "",
    version_pretty: str = "",
) -> dict[str, str]:
    """The --build-arg set passed to `podman/buildah build`."""
    return {
        "BASE_IMAGE_NAME": variant.base_image_name,
        "FEDORA_VERSION": str(variant.fedora_version),
        "BASE_IMAGE": variant.base_image,
        "IMAGE_NAME": variant.image,
        "IMAGE_VENDOR": image_vendor,
        "IMAGE_BRANCH": image_branch,
        "KERNEL_FLAVOR": variant.kernel_flavor,
        "KERNEL_VERSION": variant.kernel_version,
        "NVIDIA_FLAVOR": variant.nvidia_flavor,
        "NVIDIA_BASE": variant.nvidia_base,
        "SHA_HEAD_SHORT": sha_head_short,
        "VERSION_TAG": version_tag,
        "VERSION_PRETTY": version_pretty,
        "ARCH": variant.arch,
    }


def resolve_source_version(
    *,
    ref_name: str,
    upstream_tag: str,
    sha_short: str,
    fedora_version: int,
    pr_number: str | None = None,
) -> tuple[str, str]:
    """VERSION_TAG / VERSION_PRETTY build args, baked into the image's
    /usr/lib/os-release. `upstream_tag` is the base Fedora image's own
    version label with any trailing ".0" stripped, e.g. skopeo inspect's
    Labels["org.opencontainers.image.version"].
    """
    if pr_number:
        version = f"pr-{fedora_version}-{pr_number}"
        pretty = f"PR ({pr_number}, {upstream_tag})"
    elif ref_name == "unstable":
        version = f"unstable-{upstream_tag}"
        pretty = f"Unstable (F{upstream_tag}, #{sha_short})"
    elif ref_name == "testing":
        version = f"testing-{upstream_tag}"
        pretty = f"Testing (F{upstream_tag}, #{sha_short})"
    else:
        version = upstream_tag
        pretty = f"Stable (F{upstream_tag})"
    return version, pretty


def strip_trailing_zero(upstream_tag: str) -> str:
    """Remove a trailing ".0" so it doesn't collide with our own point releases."""
    return re.sub(r"\.\d$", "", upstream_tag)


def release_version(*, ref_name: str, fedora_version: int, today: datetime | None = None) -> str:
    """The OCI-label / registry-tag version, before point-release dedup."""
    today = today or datetime.now(timezone.utc)
    version = f"{fedora_version}.{today:%Y%m%d}"
    if ref_name == "unstable":
        version = f"unstable-{version}"
    elif ref_name == "testing":
        version = f"testing-{version}"
    return version


def dedup_version(version: str, existing_tags: set[str]) -> str:
    """Append .1, .2, ... if `version` already exists in the registry."""
    if version not in existing_tags:
        return version
    build = 1
    while True:
        candidate = f"{version}.{build}"
        if candidate not in existing_tags:
            return candidate
        build += 1


def alias_tags(*, ref_name: str, version: str, fedora_version: int) -> list[str]:
    """The floating tags (latest, stable, stable-42, ...) that should point at this version."""
    if ref_name == "unstable":
        return ["unstable", f"unstable-{fedora_version}"]
    if ref_name == "testing":
        return ["testing", f"testing-{fedora_version}"]
    return [f"stable-{version}", "latest", "stable", f"stable-{fedora_version}"]


def labels_for(variant: Variant, *, version: str, sha: str, kernel_evr: str) -> dict[str, str]:
    labels = dict(IMAGE_LABELS)
    labels["org.opencontainers.image.revision"] = sha
    labels["org.opencontainers.image.version"] = version
    labels["org.opencontainers.image.created"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    labels["ostree.bootable"] = "true"
    labels["ostree.linux"] = kernel_evr
    return labels


# ---------------------------------------------------------------------------
# Subcommands
# ---------------------------------------------------------------------------


def cmd_images(args: argparse.Namespace) -> int:
    print(json.dumps(sorted(IMAGES), indent=2 if sys.stdout.isatty() else None))
    return 0


def cmd_matrix(args: argparse.Namespace) -> int:
    """The CI job matrix: one row per image variant."""
    rows = []
    for image in sorted(IMAGES):
        v = get_variant(image)
        rows.append(
            {
                "image": v.image,
                "fedora_version": v.fedora_version,
                "kernel_flavor": v.kernel_flavor,
                "kernel_version": v.kernel_version,
                "base_image_flavor": v.base_image_flavor,
                "arch": v.arch,
            }
        )
    print(json.dumps({"include": rows}))
    return 0


def cmd_doctor(args: argparse.Namespace) -> int:
    """First command a new contributor should run."""
    ok = True

    with group("Required tools"):
        for tool in ("podman", "buildah", "skopeo", "jq", "just"):
            path = shutil.which(tool)
            if path:
                log.info("%-10s OK  (%s)", tool, path)
            else:
                log.error("%-10s MISSING -- install %s before building", tool, tool)
                ok = False

    with group("Git submodules"):
        if (REPO_ROOT / ".git").exists():
            result = run(
                ["git", "submodule", "status"],
                capture=True,
                check=False,
            )
            uninitialized = [line for line in result.stdout.splitlines() if line.startswith("-")]
            if uninitialized:
                log.error(
                    "%d submodule(s) not initialized (firmware / gnome extensions). "
                    "Run: git submodule update --init --recursive",
                    len(uninitialized),
                )
                for line in uninitialized:
                    log.error("  %s", line.strip())
                ok = False
            else:
                log.info("submodules OK")
        else:
            log.warning("not a git checkout -- skipping submodule check")

    with group("Disk space"):
        usage = shutil.disk_usage(REPO_ROOT)
        free_gb = usage.free / (1024**3)
        if free_gb < 30:
            log.warning("only %.1fGiB free -- image builds can need 30GiB+", free_gb)
        else:
            log.info("%.1fGiB free", free_gb)

    if ok:
        log.info("doctor: all checks passed")
    else:
        log.error("doctor: fix the issues above before building")
    return 0 if ok else 1


def cmd_resolve(args: argparse.Namespace) -> int:
    """Build args + labels + tags for one image, as JSON."""
    variant = get_variant(args.image)
    ref_name = args.ref_name
    sha = args.sha or "deadbeef"
    sha_short = sha[:7]

    upstream_tag = args.upstream_tag
    if upstream_tag is None:
        with group(f"Inspecting {variant.base_image}"):
            result = run(
                ["skopeo", "inspect", f"docker://{variant.base_image}"],
                capture=True,
                dry_run=args.dry_run,
            )
            if args.dry_run:
                upstream_tag = f"{variant.fedora_version}.0"
            else:
                data = json.loads(result.stdout)
                raw = data.get("Labels", {}).get("org.opencontainers.image.version")
                if not raw or raw == "null":
                    log.error("inspected image version must not be empty or null")
                    return 1
                upstream_tag = raw
    upstream_tag = strip_trailing_zero(upstream_tag)

    source_version, source_pretty = resolve_source_version(
        ref_name=ref_name,
        upstream_tag=upstream_tag,
        sha_short=sha_short,
        fedora_version=variant.fedora_version,
        pr_number=args.pr_number,
    )

    args_out = build_args(
        variant,
        image_vendor=args.image_vendor,
        image_branch=ref_name,
        sha_head_short=sha_short,
        version_tag=source_version,
        version_pretty=source_pretty,
    )

    version = release_version(ref_name=ref_name, fedora_version=variant.fedora_version)
    output_image = f"{args.push_registry}/{variant.image}"
    if not args.dry_run and not args.skip_registry:
        with group(f"Checking existing tags for {output_image}"):
            result = run(
                ["skopeo", "list-tags", f"docker://{output_image}"],
                capture=True,
                check=False,
            )
            existing = set()
            if result.returncode == 0:
                existing = set(json.loads(result.stdout).get("Tags", []))
            version = dedup_version(version, existing)

    tags = alias_tags(ref_name=ref_name, version=version, fedora_version=variant.fedora_version)
    labels = labels_for(variant, version=version, sha=sha, kernel_evr=args.kernel_evr or variant.kernel_version)

    out = {
        "image": variant.image,
        "base_image": variant.base_image,
        "container_target": variant.container_target,
        "nvidia_base": variant.nvidia_base,
        "nvidia_flavor": variant.nvidia_flavor,
        "install_nvidia": variant.install_nvidia,
        "akmods_tag": variant.akmods_tag,
        "akmods_nvidia_tag": variant.akmods_nvidia_tag,
        "output_image": output_image,
        "build_args": args_out,
        "version": version,
        "alias_tags": tags,
        "labels": labels,
    }
    print(json.dumps(out, indent=2 if sys.stdout.isatty() else None))
    return 0


def cmd_build(args: argparse.Namespace) -> int:
    """Build the image with podman/buildah.

    Local dev builds skip the registry entirely -- no upstream tag lookup,
    no version dedup -- since a contributor iterating on a package list
    doesn't care whether "44.20260820" collides with a published tag. CI
    passes --resolved-json to reuse the build args/target that `resolve`
    already computed once, rather than resolving twice.
    """
    if args.resolved_json:
        data = json.loads(Path(args.resolved_json).read_text())
        target = data["container_target"]
        args_dict = data["build_args"]
    else:
        variant = get_variant(args.image)
        target = variant.container_target
        args_dict = build_args(
            variant,
            image_branch="local",
            sha_head_short="local",
            version_tag=f"{variant.fedora_version}.dev",
            version_pretty="Local dev build",
        )

    tag = args.tag or f"localhost/{args.image}:build"
    cmd = [args.container_mgr, "build", "-f", "Containerfile", "--target", target]
    for key, value in args_dict.items():
        cmd.append(f"--build-arg={key}={value}")
    if args.secret:
        cmd += ["--secret", args.secret]
    cmd += ["--tag", tag, str(REPO_ROOT)]
    run(cmd, dry_run=args.dry_run)
    log.info("built %s", tag)
    return 0


#: Labels stamped onto the raw build that shouldn't survive into the
#: rechunked image -- ostree/rpm-ostree bookkeeping from intermediate
#: layers, buildah's own version stamp, and registry expiry hints that
#: don't apply once the image is actually published.
STALE_RECHUNK_LABELS = (
    "ostree.commit",
    "ostree.final-diffid",
    "rpmostree.inputhash",
    "quay.expires-after",
    "io.buildah.version",
)


def cmd_rechunk(args: argparse.Namespace) -> int:
    """
    Re-derives the final layer set with chunkah so related files land in
    the same OCI layer (needed for efficient delta updates). chunkah's own
    image is cosign-verified before use, same as the common/brew image
    verification pattern used elsewhere in the ublue-os pipelines. Unlike
    the old rpm-ostree-based rechunk this doesn't need --privileged, and
    chunkah prunes /run and /tmp itself so there's no separate squash step.
    """
    run(["podman", "pull", args.chunkah_image], dry_run=args.dry_run)

    if args.dry_run:
        chunkah_ref = args.chunkah_image
    else:
        inspected = run(
            ["podman", "image", "inspect", "--format", "{{index .RepoDigests 0}}", args.chunkah_image],
            capture=True,
        )
        chunkah_ref = inspected.stdout.strip()

    with group(f"Verifying {chunkah_ref}"):
        run(
            [
                "cosign", "verify",
                "--certificate-oidc-issuer", "https://token.actions.githubusercontent.com",
                "--certificate-identity-regexp", r"^https://github\.com/coreos/chunkah/",
                chunkah_ref,
            ],
            dry_run=args.dry_run,
        )

    labels = []
    if args.labels_file and Path(args.labels_file).exists():
        for line in Path(args.labels_file).read_text().splitlines():
            if line.strip():
                labels += ["--label", line]
    for stale in STALE_RECHUNK_LABELS:
        labels += ["--label", f"{stale}-"]

    with tempfile.TemporaryDirectory(prefix="rechunk-") as rechunk_dir:
        config_path = Path(rechunk_dir) / "chunkah-config.json"
        with group("Composing chunked OCI image"):
            # Carries Env, Cmd, and containers.bootc over to the chunked image.
            inspected = run(["podman", "image", "inspect", f"localhost/{args.raw_image}"], capture=True, dry_run=args.dry_run)
            if not args.dry_run:
                config_path.write_text(inspected.stdout)

            run(
                [
                    "podman", "run", "--rm", "--pull=never",
                    f"--mount=type=image,src=localhost/{args.raw_image},target=/chunkah",
                    "--volume", f"{config_path}:/chunkah-config.json:ro,Z",
                    "--volume", f"{rechunk_dir}:/run/out:Z",
                    chunkah_ref,
                    "build",
                    "--verbose", "--compressed",
                    "--max-layers", str(args.max_layers),
                    "--prune", "/sysroot/",
                    "--prune", "/run/",
                    "--prune", "/tmp/",
                    *labels,
                    "--config", "/chunkah-config.json",
                    "--output", "oci:/run/out/chunked",
                ],
                dry_run=args.dry_run,
            )

        run(["podman", "rmi", "-f", f"localhost/{args.raw_image}"], dry_run=args.dry_run, check=False)

        if args.dry_run:
            print(json.dumps({"ref": f"containers-storage:{args.chunked_image}"}))
            return 0

        pulled = run(["podman", "pull", f"oci:{rechunk_dir}/chunked"], capture=True)
        chunked_id = pulled.stdout.strip()
        run(["podman", "tag", chunked_id, args.chunked_image])

    print(json.dumps({"ref": f"containers-storage:{args.chunked_image}"}))
    return 0


def cmd_sbom(args: argparse.Namespace) -> int:
    """Export the chunked image's rootfs and run syft over it to produce an SBOM."""
    oci_dir = Path(tempfile.mkdtemp(prefix="image-oci-"))
    rootfs = oci_dir / "rootfs"
    rootfs.mkdir(parents=True)
    try:
        run(
            [args.container_mgr, "container", "create", "--replace", "--name", args.image, args.chunked_image],
            dry_run=args.dry_run,
        )
        export_cmd = [args.container_mgr, "export", args.image]
        tar_cmd = ["tar", "-C", str(rootfs), "--no-same-owner", "-xf", "-"]
        log.info("+ %s | %s", " ".join(export_cmd), " ".join(tar_cmd))
        if not args.dry_run:
            export = subprocess.Popen(export_cmd, stdout=subprocess.PIPE)
            subprocess.run(tar_cmd, stdin=export.stdout, check=True)
            export.stdout.close()
            export.wait()
        run([args.container_mgr, "container", "rm", args.image], dry_run=args.dry_run, check=False)

        sbom_path = Path(tempfile.mkdtemp(prefix="sbom-")) / "sbom.json"
        source_name = f"{args.image}-{args.version_tag}"
        env = {"SYFT_PARALLELISM": str((os.cpu_count() or 1) * 2)}
        run(
            [args.syft_cmd, "--source-name", source_name, str(rootfs), "-o", f"syft-json={sbom_path}"],
            dry_run=args.dry_run,
            env=env,
        )
        print(json.dumps({"sbom": str(sbom_path)}))
        return 0
    finally:
        shutil.rmtree(oci_dir, ignore_errors=True)


def cmd_test(args: argparse.Namespace) -> int:
    """Run the goss test suite against a built image. Thin passthrough so CI and
    local iteration share one entrypoint; tests/dgoss/ itself is untouched.
    """
    run(["tests/dgoss/dgoss-tests.sh", "tests/dgoss/tests.d", args.ref], dry_run=args.dry_run)
    return 0


def cmd_push(args: argparse.Namespace) -> int:
    """Push the rechunked image to GHCR and copy its digest onto the alias tags.

    Pushes twice on purpose: a single `podman push` can report a digest
    that doesn't match what's actually readable back from the registry
    (containers/podman#27796), and everything downstream -- signing, SBOM
    attach, attestation -- keys off this digest. The second push's digest
    is the one that's actually stable. CI wraps this whole command in
    nick-fields/retry, so a transient registry failure retries the full
    push+tag sequence as a unit, not just one podman call.
    """
    rechunk_ref = args.rechunk_ref.removeprefix("containers-storage:")
    target = f"{args.output_image}:{args.version}"
    summary = ["# Push to GHCR result", "```"]

    digestfile = Path(tempfile.mktemp(prefix="digestfile-"))
    try:
        for _ in range(2):
            run(
                ["podman", "push", f"--digestfile={digestfile}", rechunk_ref, f"docker://{target}"],
                dry_run=args.dry_run,
            )
        summary.append(target)

        if args.dry_run:
            digest = "sha256:dryrun"
        else:
            digest = digestfile.read_text().strip()
            if not digest:
                raise CommandError("push reported success but wrote no digest")
    finally:
        digestfile.unlink(missing_ok=True)

    for tag in args.alias_tags.split():
        run(
            ["skopeo", "copy", f"docker://{args.output_image}@{digest}", f"docker://{args.output_image}:{tag}"],
            dry_run=args.dry_run,
        )
        summary.append(f"{args.output_image}:{tag}")
    summary.append("```")

    summary_text = "\n".join(summary)
    if args.summary_file:
        with open(args.summary_file, "a") as f:
            f.write(summary_text + "\n")
    log.info("%s", summary_text)

    print(json.dumps({"digest": digest}))
    return 0


def cmd_sign(args: argparse.Namespace) -> int:
    """Cosign-sign a ref -- the image or its SBOM artifact, whichever is passed.

    Reads COSIGN_PRIVATE_KEY from the environment.
    """
    run(
        [
            "cosign", "sign", "-y", "--key", "env://COSIGN_PRIVATE_KEY",
            "--new-bundle-format=false", "--use-signing-config=false",
            args.ref,
        ],
        dry_run=args.dry_run,
    )
    return 0


def cmd_sbom_attach(args: argparse.Namespace) -> int:
    """Attach the SBOM as an OCI referrer artifact on the image digest, then
    look up its own digest so it can be signed in turn.
    """
    sbom_path = Path(args.sbom)
    run(
        [
            "oras", "attach",
            "--artifact-type", "application/vnd.spdx+json",
            "--annotation", f"filename={sbom_path.name}",
            f"{args.image}@{args.digest}",
            str(sbom_path),
        ],
        dry_run=args.dry_run,
    )

    if args.dry_run:
        sbom_digest = "sha256:dryrun-sbom"
    else:
        result = run(["oras", "discover", "--format", "json", f"{args.image}@{args.digest}"], capture=True)
        referrers = json.loads(result.stdout).get("referrers", [])
        matches = [r["digest"] for r in referrers if r.get("artifactType") == "application/vnd.spdx+json"]
        if not matches:
            raise CommandError("no application/vnd.spdx+json referrer found after oras attach")
        sbom_digest = matches[0]

    print(json.dumps({"sbom_digest": sbom_digest}))
    return 0


def cmd_shell(args: argparse.Namespace) -> int:
    """Build the image if it doesn't exist locally, then drop into a shell in it."""
    tag = f"localhost/{args.image}:build"
    check = run(
        [args.container_mgr, "images", "--filter", f"reference={tag}", "--format", "{{.ID}}"],
        capture=True,
        check=False,
        dry_run=args.dry_run,
    )
    if not args.dry_run and not check.stdout.strip():
        log.info("%s not built yet, building first", tag)
        cmd_build(args)
    run([args.container_mgr, "run", "-it", "--rm", tag, "/usr/bin/bash"], dry_run=args.dry_run)
    return 0


def detect_container_mgr() -> str:
    override = os.environ.get("CONTAINER_MGR")
    if override:
        return override
    for candidate in ("docker", "podman", "podman-remote"):
        if shutil.which(candidate):
            return candidate
    raise CommandError("no container manager found (looked for docker, podman, podman-remote)")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("-v", "--verbose", action="count", default=0)
    parser.add_argument("-q", "--quiet", action="count", default=0)
    parser.add_argument("--dry-run", action="store_true", help="print commands instead of running them")

    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("doctor", help="check your machine is set up to build").set_defaults(func=cmd_doctor)
    sub.add_parser("images", help="list valid --image values").set_defaults(func=cmd_images)
    sub.add_parser("matrix", help="print the GitHub Actions build matrix as JSON").set_defaults(func=cmd_matrix)

    p_resolve = sub.add_parser("resolve", help="print build args/labels/tags for one image as JSON")
    p_resolve.add_argument("--image", default=DEFAULT_IMAGE, choices=sorted(IMAGES))
    p_resolve.add_argument("--ref-name", default=os.environ.get("GITHUB_REF_NAME", "main"))
    p_resolve.add_argument("--sha", default=os.environ.get("GITHUB_SHA"))
    p_resolve.add_argument("--pr-number", default=os.environ.get("PR_NUMBER"))
    p_resolve.add_argument("--image-vendor", default=IMAGE_VENDOR_DEFAULT)
    p_resolve.add_argument("--push-registry", default=PULL_REGISTRY)
    p_resolve.add_argument("--upstream-tag", default=None, help="skip the skopeo inspect and use this instead")
    p_resolve.add_argument("--kernel-evr", default=None, help="skip the in-image rpm query and use this instead")
    p_resolve.add_argument("--skip-registry", action="store_true", help="skip point-release dedup against the registry")
    p_resolve.set_defaults(func=cmd_resolve)

    p_build = sub.add_parser("build", help="build one image locally")
    p_build.add_argument("--image", default=DEFAULT_IMAGE, choices=sorted(IMAGES))
    p_build.add_argument("--container-mgr", default=None)
    p_build.add_argument("--resolved-json", default=None, help="reuse build args/target from `resolve`'s output (CI)")
    p_build.add_argument("--tag", default=None)
    p_build.add_argument("--secret", default=None, help="passed through to --secret (e.g. id=GITHUB_TOKEN,env=GITHUB_TOKEN)")
    p_build.set_defaults(func=cmd_build)

    p_shell = sub.add_parser("shell", help="build if needed, then shell into the image")
    p_shell.add_argument("--image", default=DEFAULT_IMAGE, choices=sorted(IMAGES))
    p_shell.add_argument("--container-mgr", default=None)
    p_shell.set_defaults(func=cmd_shell)

    p_rechunk = sub.add_parser("rechunk", help="rechunk a raw build into an OCI image via chunkah")
    p_rechunk.add_argument("--raw-image", default="raw-img")
    p_rechunk.add_argument("--chunked-image", default="localhost/chunked-img")
    p_rechunk.add_argument("--chunkah-image", default="quay.io/coreos/chunkah:latest")
    p_rechunk.add_argument("--labels-file", default=None)
    p_rechunk.add_argument("--max-layers", type=int, default=128)
    p_rechunk.set_defaults(func=cmd_rechunk)

    p_sbom = sub.add_parser("sbom", help="generate a syft SBOM for a rechunked image")
    p_sbom.add_argument("--image", default=DEFAULT_IMAGE, choices=sorted(IMAGES))
    p_sbom.add_argument("--chunked-image", default="localhost/chunked-img")
    p_sbom.add_argument("--version-tag", default="dev")
    p_sbom.add_argument("--container-mgr", default=None)
    p_sbom.add_argument("--syft-cmd", default="syft")
    p_sbom.set_defaults(func=cmd_sbom)

    p_test = sub.add_parser("test", help="run the goss test suite against an image ref")
    p_test.add_argument("--ref", required=True)
    p_test.set_defaults(func=cmd_test)

    p_push = sub.add_parser("push", help="push a rechunked image and its alias tags to a registry")
    p_push.add_argument("--output-image", required=True)
    p_push.add_argument("--version", required=True)
    p_push.add_argument("--alias-tags", required=True, help="space-separated list of alias tags")
    p_push.add_argument("--rechunk-ref", required=True, help="e.g. containers-storage:localhost/chunked-img")
    p_push.add_argument("--summary-file", default=os.environ.get("GITHUB_STEP_SUMMARY"))
    p_push.set_defaults(func=cmd_push)

    p_sign = sub.add_parser("sign", help="cosign sign a ref using COSIGN_PRIVATE_KEY from the environment")
    p_sign.add_argument("--ref", required=True)
    p_sign.set_defaults(func=cmd_sign)

    p_sbom_attach = sub.add_parser("sbom-attach", help="attach an SBOM file to an image digest via oras")
    p_sbom_attach.add_argument("--image", required=True)
    p_sbom_attach.add_argument("--digest", required=True)
    p_sbom_attach.add_argument("--sbom", required=True)
    p_sbom_attach.set_defaults(func=cmd_sbom_attach)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    setup_logging(args.verbose - args.quiet)

    if hasattr(args, "container_mgr") and args.container_mgr is None:
        args.container_mgr = detect_container_mgr()

    try:
        return args.func(args)
    except (CommandError, ValueError) as exc:
        log.error(str(exc))
        return 1


if __name__ == "__main__":
    sys.exit(main())
