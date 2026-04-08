from itertools import product
import subprocess
import json
import os
import tempfile
import time
from typing import Any
import re
from collections import defaultdict

REGISTRY = "ghcr.io/ublue-os/"

IMAGES = [
    "bazzite",
    "bazzite-gnome",
    "bazzite-nvidia",
    "bazzite-gnome-nvidia",
    "bazzite-nvidia-open",
    "bazzite-gnome-nvidia-open",
]

RETRIES = 3
RETRY_WAIT = 5
FEDORA_PATTERN = re.compile(r"\.fc\d\d")
EPOCH_PATTERN = re.compile(r"^\d+:")
STABLE_START_PATTERN = re.compile(r"\d\d\.\d")
OTHER_START_PATTERN = lambda target: re.compile(rf"{target}-\d\d\.\d")

PATTERN_ADD = "\n| ✨ | {name} | | {version} |"
PATTERN_CHANGE = "\n| 🔄 | {name} | {prev} | {new} |"
PATTERN_REMOVE = "\n| ❌ | {name} | {version} | |"
PATTERN_PKGREL_CHANGED = "{prev} ➡️ {new}"
PATTERN_PKGREL = "{version}"
COMMON_PAT = "### All Images\n| | Name | Previous | New |\n| --- | --- | --- | --- |{changes}\n\n"
OTHER_NAMES = {
    "desktop": "### Desktop Images\n| | Name | Previous | New |\n| --- | --- | --- | --- |{changes}\n\n",
    "deck": "### Deck Images\n| | Name | Previous | New |\n| --- | --- | --- | --- |{changes}\n\n",
    "kde": "### KDE Images\n| | Name | Previous | New |\n| --- | --- | --- | --- |{changes}\n\n",
    "gnome": "### Gnome Images\n| | Name | Previous | New |\n| --- | --- | --- | --- |{changes}\n\n",
    "nvidia": "### Nvidia Images\n| | Name | Previous | New |\n| --- | --- | --- | --- |{changes}\n\n",
}

COMMITS_FORMAT = (
    "### Commits\n| Hash | Subject | Author |\n| --- | --- | --- |{commits}\n\n"
)
COMMIT_FORMAT = "\n| **[{short}](https://github.com/ublue-os/bazzite/commit/{hash})** | {subject} | {author} |"

CHANGELOG_TITLE = "{tag}: {pretty}"
CHANGELOG_FORMAT = """\
{handwritten}

From previous `{target}` version `{prev}` there have been the following changes. **One package per new version shown.**

### Major packages
| Name | Version |
| --- | --- |
| **Kernel** | {pkgrel:kernel} |
| **Firmware** | {pkgrel:atheros-firmware} |
| **Mesa** | {pkgrel:mesa-filesystem} |
| **Gamescope** | {pkgrel:terra-gamescope} |
| **Bazaar** | {pkgrel:bazaar} |
| **Gnome** | {pkgrel:gnome-control-center-filesystem} |
| **KDE** | {pkgrel:plasma-desktop} |
| **Nvidia Open** | {pkgrel:nvidia-kmod-common} |
| **Nvidia LTS** | {pkgrel:nvidia-kmod-common-lts} |

{changes}

### How to rebase
For current users, type the following to rebase to this version:
```bash
# For this branch (if latest):
bazzite-rollback-helper rebase {target}
# For this specific image:
bazzite-rollback-helper rebase {curr}
```
"""
HANDWRITTEN_PLACEHOLDER = """\
This is an automatically generated changelog for release `{curr}`."""

BLACKLIST_VERSIONS = [
    "kernel",
    "mesa-filesystem",
    "terra-gamescope",
    "gamescope-session",
    "inputplumber",
    "powerstation",
    "steamos-manager-powerstation",
    "opengamepadui",
    "bazaar",
    "gnome-control-center-filesystem",
    "plasma-desktop",
    "atheros-firmware",
    "nvidia-kmod-common",
    "nvidia-kmod-common-lts",
]

PKG_ALIAS = {
}


def get_images():
    for img in IMAGES:
        if "deck" in img:
            base = "deck"
        else:
            base = "desktop"

        if "gnome" in img:
            de = "gnome"
        else:
            de = "kde"

        yield img, base, de


def get_manifests(target: str):
    out = {}
    imgs = list(get_images())
    for j, (img, _, _) in enumerate(imgs):
        output = None
        print(f"Getting {img}:{target} manifest ({j+1}/{len(imgs)}).")
        for i in range(RETRIES):
            try:
                output = subprocess.run(
                    ["skopeo", "inspect", "docker://" + REGISTRY + img + ":" + target],
                    check=True,
                    stdout=subprocess.PIPE,
                ).stdout
                break
            except subprocess.CalledProcessError:
                print(
                    f"Failed to get {img}:{target}, retrying in {RETRY_WAIT} seconds ({i+1}/{RETRIES})"
                )
                time.sleep(RETRY_WAIT)
        if output is None:
            print(f"Failed to get {img}:{target}, skipping")
            continue
        out[img] = json.loads(output)
    return out


def get_image_digest(image: str, tag: str) -> str:
    """Get image digest using skopeo."""
    result = subprocess.run(
        ["skopeo", "inspect", f"docker://{image}:{tag}"],
        capture_output=True,
        text=True,
        check=True,
    )
    return json.loads(result.stdout)["Digest"]


def get_sbom(image: str, digest: str) -> dict:
    """Fetch SBOM using ORAS."""
    full_ref = f"{image}@{digest}"

    result = subprocess.run(
        ["oras", "discover", "--format", "json", full_ref],
        capture_output=True,
        text=True,
        check=True,
    )
    discovered = json.loads(result.stdout)

    sbom_digest = None
    for referrer in discovered.get("referrers", []):
        if "spdx+json" in referrer.get("artifactType", ""):
            sbom_digest = referrer["digest"]
            break

    if sbom_digest is None:
        raise RuntimeError(f"No SBOM referrer found for {full_ref}")

    sbom_ref = f"{image}@{sbom_digest}"

    with tempfile.TemporaryDirectory() as tmpdir:
        subprocess.run(
            ["oras", "pull", sbom_ref],
            capture_output=True,
            check=True,
            cwd=tmpdir,
        )

        for fname in os.listdir(tmpdir):
            fpath = os.path.join(tmpdir, fname)
            if fname.endswith(".zst"):
                result = subprocess.run(
                    ["zstd", "-d", fpath, "--stdout"],
                    capture_output=True,
                    check=True,
                )
                return json.loads(result.stdout)
            elif fname.endswith(".json"):
                with open(fpath) as f:
                    return json.load(f)

    raise RuntimeError(f"No SBOM file found after pulling {sbom_ref}")


def parse_sbom_packages(sbom: dict) -> dict[str, str]:
    """Parse RPM packages from a Syft-format SBOM."""
    packages = {}
    for artifact in sbom.get("artifacts", []):
        if artifact.get("type") != "rpm":
            continue
        name = artifact.get("name")
        version = artifact.get("version")
        if name and version:
            if name not in packages or (":" in version and ":" not in packages[name]):
                packages[name] = version
    return packages


def get_tags(target: str, manifests: dict[str, Any]):
    tags = set()

    # Select random manifest to get reference tags from
    first = next(iter(manifests.values()))
    for tag in first["RepoTags"]:
        # Tags ending with .0 should not exist
        if tag.endswith(".0"):
            continue
        if target != "stable":
            if re.match(OTHER_START_PATTERN(target), tag):
                tags.add(tag)
        else:
            if re.match(STABLE_START_PATTERN, tag):
                tags.add(tag)

    # Remove tags not present in all images
    for manifest in manifests.values():
        for tag in list(tags):
            if tag not in manifest["RepoTags"]:
                tags.remove(tag)

    tags = list(sorted(tags))
    assert len(tags) > 2, "No current and previous tags found"
    return tags[-2], tags[-1]


def get_packages(tag: str):
    packages = {}
    imgs = list(get_images())
    for j, (img, _, _) in enumerate(imgs):
        print(f"Getting packages for {img}:{tag} via SBOM ({j+1}/{len(imgs)})")
        try:
            full_image = REGISTRY + img
            digest = get_image_digest(full_image, tag)
            sbom = get_sbom(full_image, digest)
            packages[img] = parse_sbom_packages(sbom)
            print(f"  Found {len(packages[img])} packages")
        except Exception as e:
            print(f"  Failed to get packages for {img}:{tag}: {e}")
            raise
    return packages


def is_nvidia(img: str, lts: bool):
    if lts:
        return "nvidia" in img and "nvidia-open" not in img and "deck-nvidia" not in img
    else:
        return "nvidia-open" in img or "deck-nvidia" in img


def get_package_groups(prev_tag: str, curr_tag: str):
    common = set()
    others = {k: set() for k in OTHER_NAMES.keys()}

    print(f"\nFetching current packages for {curr_tag}...")
    npkg = get_packages(curr_tag)
    print(f"\nFetching previous packages for {prev_tag}...")
    ppkg = get_packages(prev_tag)

    keys = set(npkg.keys()) | set(ppkg.keys())
    pkg = defaultdict(set)
    for k in keys:
        pkg[k] = set(npkg.get(k, {})) | set(ppkg.get(k, {}))

    # Find common packages
    first = True
    for img, base, de in get_images():
        if img not in pkg:
            continue

        if first:
            for p in pkg[img]:
                common.add(p)
        else:
            for c in common.copy():
                if c not in pkg[img]:
                    common.remove(c)

        first = False

    # Find other packages
    for t, other in others.items():
        first = True
        for img, base, de in get_images():
            if img not in pkg:
                continue

            if t == "nvidia" and "nvidia" not in img:
                continue
            if t == "kde" and de != "kde":
                continue
            if t == "gnome" and de != "gnome":
                continue
            if t == "deck" and base != "deck":
                continue
            if t == "desktop" and base == "deck":
                continue

            if first:
                for p in pkg[img]:
                    if p not in common:
                        other.add(p)
            else:
                for c in other.copy():
                    if c not in pkg[img]:
                        other.remove(c)

            first = False

    return sorted(common), {k: sorted(v) for k, v in others.items()}, npkg, ppkg


def get_versions(packages: dict[str, dict[str, str]]):
    versions = {}
    for img, img_pkgs in packages.items():
        for pkg, v in img_pkgs.items():
            if is_nvidia(img, lts=True) and "nvidia" in pkg:
                pkg += "-lts"
            v = re.sub(EPOCH_PATTERN, "", v)
            versions[pkg] = re.sub(FEDORA_PATTERN, "", v)
    return versions


def calculate_changes(pkgs: list[str], prev: dict[str, str], curr: dict[str, str]):
    added = []
    changed = []
    removed = []

    blacklist_ver = set([curr.get(v, None) for v in BLACKLIST_VERSIONS])

    for pkg in pkgs:
        # Clearup changelog by removing mentioned packages
        if pkg in BLACKLIST_VERSIONS:
            continue
        if pkg in curr and curr.get(pkg, None) in blacklist_ver:
            continue
        if pkg in prev and prev.get(pkg, None) in blacklist_ver:
            continue
        if pkg.endswith("-lts"):
            continue

        if pkg not in prev:
            added.append(pkg)
        elif pkg not in curr:
            removed.append(pkg)
        elif prev[pkg] != curr[pkg]:
            changed.append(pkg)

        blacklist_ver.add(curr.get(pkg, None))
        blacklist_ver.add(prev.get(pkg, None))

    out = ""
    for pkg in added:
        out += PATTERN_ADD.format(name=pkg, version=curr[pkg])
    for pkg in changed:
        out += PATTERN_CHANGE.format(name=pkg, prev=prev[pkg], new=curr[pkg])
    for pkg in removed:
        out += PATTERN_REMOVE.format(name=pkg, version=prev[pkg])
    return out


def get_commits(prev_manifests, manifests, workdir: str):
    try:
        start = next(iter(prev_manifests.values()))["Labels"][
            "org.opencontainers.image.revision"
        ]
        finish = next(iter(manifests.values()))["Labels"][
            "org.opencontainers.image.revision"
        ]

        commits = subprocess.run(
            [
                "git",
                "-C",
                workdir,
                "log",
                "--pretty=format:%H|%h|%an|%s",
                f"{start}..{finish}",
            ],
            check=True,
            stdout=subprocess.PIPE,
        ).stdout.decode("utf-8")

        out = ""
        for commit in commits.split("\n"):
            if not commit:
                continue
            parts = commit.split("|")
            if len(parts) < 4:
                continue
            commit_hash, short, author, subject = parts

            if subject.lower().startswith("merge"):
                continue

            out += (
                COMMIT_FORMAT.replace("{short}", short)
                .replace("{subject}", subject)
                .replace("{hash}", commit_hash)
                .replace("{author}", author)
            )

        if out:
            return COMMITS_FORMAT.format(commits=out)
        return ""
    except Exception as e:
        print(f"Failed to get commits:\n{e}")
        return ""


def generate_changelog(
    handwritten: str | None,
    target: str,
    pretty: str | None,
    workdir: str,
    prev_tag: str,
    curr_tag: str,
    prev_manifests,
    manifests,
):
    common, others, curr_packages, prev_packages = get_package_groups(prev_tag, curr_tag)
    versions = get_versions(curr_packages)
    prev_versions = get_versions(prev_packages)

    prev, curr = prev_tag, curr_tag

    if not pretty:
        # Generate pretty version since we dont have it
        try:
            finish: str = next(iter(manifests.values()))["Labels"][
                "org.opencontainers.image.revision"
            ]
        except Exception as e:
            print(f"Failed to get finish hash:\n{e}")
            finish = ""

        # Remove .0 from curr
        curr_pretty = re.sub(r"\.\d{1,2}$", "", curr)
        # Remove target- from curr
        curr_pretty = re.sub(rf"^[a-z]+-", "", curr_pretty)
        pretty = target.capitalize() + " (F" + curr_pretty
        if finish and target != "stable":
            pretty += ", #" + finish[:7]
        pretty += ")"

    title = CHANGELOG_TITLE.format_map(defaultdict(str, tag=curr, pretty=pretty))

    changelog = CHANGELOG_FORMAT

    changelog = (
        changelog.replace(
            "{handwritten}", handwritten if handwritten else HANDWRITTEN_PLACEHOLDER
        )
        .replace("{target}", target)
        .replace("{prev}", prev)
        .replace("{curr}", curr)
    )

    for pkg, v in versions.items():
        if pkg not in prev_versions or prev_versions[pkg] == v:
            changelog = changelog.replace(
                "{pkgrel:" + (PKG_ALIAS.get(pkg, None) or pkg) + "}",
                PATTERN_PKGREL.format(version=v),
            )
        else:
            changelog = changelog.replace(
                "{pkgrel:" + (PKG_ALIAS.get(pkg, None) or pkg) + "}",
                PATTERN_PKGREL_CHANGED.format(prev=prev_versions[pkg], new=v),
            )

    changes = ""
    changes += get_commits(prev_manifests, manifests, workdir)
    common = calculate_changes(common, prev_versions, versions)
    if common:
        changes += COMMON_PAT.format(changes=common)
    for k, v in others.items():
        chg = calculate_changes(v, prev_versions, versions)
        if chg:
            changes += OTHER_NAMES[k].format(changes=chg)

    changelog = changelog.replace("{changes}", changes)

    return title, changelog


def main():
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("target", help="Target tag")
    parser.add_argument("output", help="Output environment file")
    parser.add_argument("changelog", help="Output changelog file")
    parser.add_argument("--pretty", help="Subject for the changelog")
    parser.add_argument("--workdir", help="Git directory for commits")
    parser.add_argument("--handwritten", help="Handwritten changelog")
    args = parser.parse_args()

    # Remove refs/tags, refs/heads, refs/remotes e.g.
    # Tags cannot include / anyway.
    target = args.target.split("/")[-1]

    if target == "main":
        target = "stable"

    manifests = get_manifests(target)
    prev, curr = get_tags(target, manifests)
    print(f"Previous tag: {prev}")
    print(f" Current tag: {curr}")

    prev_manifests = get_manifests(prev)
    title, changelog = generate_changelog(
        args.handwritten,
        target,
        args.pretty,
        args.workdir,
        prev,
        curr,
        prev_manifests,
        manifests,
    )

    print(f"Changelog:\n# {title}\n{changelog}")
    print(f'\nOutput:\nTITLE="{title}"\nTAG={curr}')

    with open(args.changelog, "w") as f:
        f.write(changelog)

    with open(args.output, "w") as f:
        f.write(f'TITLE="{title}"\nTAG={curr}\n')


if __name__ == "__main__":
    main()
