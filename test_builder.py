"""Golden tests for build.py.

Run with: python3 -m pytest test_builder.py -v

These lock down the variant table and version/tag logic so a future edit
can't silently change what gets published. See build.py's IMAGES table
comment for why the table is hand-written rather than derived.
"""

import json
import logging
import re
import subprocess
from datetime import datetime, timezone

import pytest

import build as b

# The release being built is data, not something the tests pin: they read
# it from build.py so a Fedora or kernel bump only touches build.py.
FEDORA = b.DEFAULTS["fedora_version"]
KERNEL = b.DEFAULTS["kernel_version"]
LTS_KERNEL = b.LTS_KERNEL_VERSION


@pytest.fixture(autouse=True)
def no_ci_env(monkeypatch):
    """Clear the GitHub Actions environment.

    build.py takes --sha, --ref-name, --pr-number, and --summary-file defaults
    from it, so tests would otherwise behave differently on a runner.
    """
    for var in (
        "GITHUB_ACTIONS", "GITHUB_SHA", "GITHUB_REF_NAME", "PR_NUMBER",
        "GITHUB_STEP_SUMMARY", "RUNNER_TEMP",
    ):
        monkeypatch.delenv(var, raising=False)

# Written out by hand from the naming rules (gnome -> silverblue, nvidia ->
# install_nvidia, plain nvidia -> nvidia-lts on the LTS kernel) rather than
# copied from build.py's IMAGES table. The exception is nvidia_flavor on the
# four images without nvidia: it's nvidia-open because the Containerfile
# always pulls akmods-${NVIDIA_FLAVOR} for the image's kernel, and
# akmods-nvidia-lts has no tag for the main kernel.
EXPECTED_VARIANTS = {
    "bazzite": {
        "base_image_name": "kinoite", "container_target": "bazzite",
        "nvidia_base": "bazzite", "nvidia_flavor": "nvidia-open", "install_nvidia": False,
        "kernel_flavor": "ogc", "kernel_version": KERNEL,
    },
    "bazzite-gnome": {
        "base_image_name": "silverblue", "container_target": "bazzite",
        "nvidia_base": "bazzite", "nvidia_flavor": "nvidia-open", "install_nvidia": False,
        "kernel_flavor": "ogc", "kernel_version": KERNEL,
    },
    "bazzite-deck": {
        "base_image_name": "kinoite", "container_target": "bazzite-deck",
        "nvidia_base": "bazzite-deck", "nvidia_flavor": "nvidia-open", "install_nvidia": False,
        "kernel_flavor": "ogc", "kernel_version": KERNEL,
    },
    "bazzite-deck-gnome": {
        "base_image_name": "silverblue", "container_target": "bazzite-deck",
        "nvidia_base": "bazzite-deck", "nvidia_flavor": "nvidia-open", "install_nvidia": False,
        "kernel_flavor": "ogc", "kernel_version": KERNEL,
    },
    "bazzite-deck-nvidia": {
        "base_image_name": "kinoite", "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite-deck", "nvidia_flavor": "nvidia-open", "install_nvidia": True,
        "kernel_flavor": "ogc", "kernel_version": KERNEL,
    },
    "bazzite-deck-nvidia-gnome": {
        "base_image_name": "silverblue", "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite-deck", "nvidia_flavor": "nvidia-open", "install_nvidia": True,
        "kernel_flavor": "ogc", "kernel_version": KERNEL,
    },
    "bazzite-nvidia": {
        "base_image_name": "kinoite", "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite", "nvidia_flavor": "nvidia-lts", "install_nvidia": True,
        "kernel_flavor": "ogc-lts", "kernel_version": LTS_KERNEL,
    },
    "bazzite-gnome-nvidia": {
        "base_image_name": "silverblue", "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite", "nvidia_flavor": "nvidia-lts", "install_nvidia": True,
        "kernel_flavor": "ogc-lts", "kernel_version": LTS_KERNEL,
    },
    "bazzite-nvidia-open": {
        "base_image_name": "kinoite", "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite", "nvidia_flavor": "nvidia-open", "install_nvidia": True,
        "kernel_flavor": "ogc", "kernel_version": KERNEL,
    },
    "bazzite-gnome-nvidia-open": {
        "base_image_name": "silverblue", "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite", "nvidia_flavor": "nvidia-open", "install_nvidia": True,
        "kernel_flavor": "ogc", "kernel_version": KERNEL,
    },
}


def test_images_table_has_expected_images():
    assert set(b.IMAGES) == set(EXPECTED_VARIANTS)


@pytest.mark.parametrize("image", sorted(EXPECTED_VARIANTS))
def test_variant_matches_expected(image):
    variant = b.get_variant(image)
    expected = EXPECTED_VARIANTS[image]
    assert variant.base_image_name == expected["base_image_name"]
    assert variant.container_target == expected["container_target"]
    assert variant.nvidia_base == expected["nvidia_base"]
    assert variant.nvidia_flavor == expected["nvidia_flavor"]
    assert variant.install_nvidia == expected["install_nvidia"]
    assert variant.kernel_flavor == expected["kernel_flavor"]
    assert variant.kernel_version == expected["kernel_version"]
    assert variant.fedora_version == FEDORA
    assert variant.base_image == f"ghcr.io/ublue-os/{expected['base_image_name']}-main:{FEDORA}"


@pytest.mark.parametrize("kernel", [KERNEL, LTS_KERNEL])
def test_kernels_are_built_for_the_fedora_release(kernel):
    """Catches a Fedora bump that forgets a kernel, or the reverse."""
    assert kernel.endswith(f".fc{FEDORA}")


def test_unknown_image_raises_with_valid_list():
    with pytest.raises(ValueError, match="unknown image"):
        b.get_variant("bazzite-does-not-exist")


# --- resolve_pretty_version ---

def test_pretty_version_stable():
    pretty = b.resolve_pretty_version(
        ref_name="main", version="45.20261013", sha_short="abc1234", fedora_version=45,
    )
    assert pretty == "Stable (F45.20261013)"


def test_pretty_version_unstable():
    pretty = b.resolve_pretty_version(
        ref_name="unstable", version="unstable-45.20261013.2",
        sha_short="abc1234", fedora_version=45,
    )
    assert pretty == "Unstable (F45.20261013.2, #abc1234)"


def test_pretty_version_testing():
    pretty = b.resolve_pretty_version(
        ref_name="testing", version="testing-45.20261014",
        sha_short="c500b43", fedora_version=45,
    )
    assert pretty == "Testing (F45.20261014, #c500b43)"


def test_pretty_version_pr_number_takes_priority_over_ref():
    # pr_number takes priority regardless of ref_name
    pretty = b.resolve_pretty_version(
        ref_name="unstable", version="unstable-45.20261013", sha_short="abc1234",
        fedora_version=45, pr_number="42",
    )
    assert pretty == "PR (42, F45.20261013, #abc1234)"


# --- release_version / dedup_version ---

def test_release_version_stable():
    today = datetime(2026, 8, 20, tzinfo=timezone.utc)
    assert b.release_version(ref_name="main", fedora_version=44, today=today) == "44.20260820"


def test_release_version_unstable_prefix():
    today = datetime(2026, 8, 20, tzinfo=timezone.utc)
    assert b.release_version(ref_name="unstable", fedora_version=44, today=today) == "unstable-44.20260820"


def test_release_version_testing_prefix():
    today = datetime(2026, 8, 20, tzinfo=timezone.utc)
    assert b.release_version(ref_name="testing", fedora_version=44, today=today) == "testing-44.20260820"


def test_dedup_version_no_collision():
    assert b.dedup_version("44.20260820", set()) == "44.20260820"


def test_dedup_version_first_collision():
    assert b.dedup_version("44.20260820", {"44.20260820"}) == "44.20260820.1"


def test_dedup_version_multiple_collisions():
    existing = {"44.20260820", "44.20260820.1", "44.20260820.2"}
    assert b.dedup_version("44.20260820", existing) == "44.20260820.3"


# --- alias_tags ---

def test_alias_tags_stable():
    tags = b.alias_tags(ref_name="main", version="44.20260820", fedora_version=44)
    assert tags == ["stable-44.20260820", "latest", "stable", "stable-44"]


def test_alias_tags_unstable():
    tags = b.alias_tags(ref_name="unstable", version="unstable-44.20260820", fedora_version=44)
    assert tags == ["unstable", "unstable-44"]


def test_alias_tags_testing():
    tags = b.alias_tags(ref_name="testing", version="testing-44.20260820", fedora_version=44)
    assert tags == ["testing", "testing-44"]


# --- build_args ---

def test_build_args_match_containerfile_args():
    """The args build.py passes, the Containerfile's ARGs, and this list agree.

    ARGs declared before the first stage are only visible to FROM lines, so
    anything a build script reads has to be in the stage.
    """
    args = b.build_args(
        b.get_variant("bazzite-deck-nvidia"), image_vendor="ublue-os", image_branch="main",
        sha_head_short="abc1234", version_tag="44", version_pretty="Stable (F44)",
    )
    stage_args = {
        "BASE_IMAGE_NAME", "FEDORA_VERSION", "IMAGE_NAME", "IMAGE_VENDOR", "IMAGE_BRANCH",
        "KERNEL_FLAVOR", "NVIDIA_FLAVOR", "SHA_HEAD_SHORT", "VERSION_TAG", "VERSION_PRETTY",
        "BUILD_DECK", "BUILD_NVIDIA",
    }
    from_only_args = {"BASE_IMAGE", "KERNEL_VERSION", "NVIDIA_BASE", "ARCH"}
    assert set(args) == stage_args | from_only_args

    def declared(text):
        return set(re.findall(r"^ARG ([A-Z_]+)", text, flags=re.MULTILINE))

    before_stage, stage = (b.REPO_ROOT / "Containerfile").read_text().split("FROM base-image AS bazzite")
    assert declared(stage) == stage_args
    assert declared(before_stage) | declared(stage) == set(args)
    assert args["SHA_HEAD_SHORT"] == "abc1234"  # never empty


@pytest.mark.parametrize(
    ("image", "deck", "nvidia"),
    [
        ("bazzite", "FALSE", "FALSE"),
        ("bazzite-gnome", "FALSE", "FALSE"),
        ("bazzite-deck", "TRUE", "FALSE"),
        ("bazzite-deck-gnome", "TRUE", "FALSE"),
        ("bazzite-nvidia", "FALSE", "TRUE"),
        ("bazzite-gnome-nvidia", "FALSE", "TRUE"),
        ("bazzite-nvidia-open", "FALSE", "TRUE"),
        ("bazzite-gnome-nvidia-open", "FALSE", "TRUE"),
        ("bazzite-deck-nvidia", "TRUE", "TRUE"),
        ("bazzite-deck-nvidia-gnome", "TRUE", "TRUE"),
    ],
)
def test_build_args_deck_and_nvidia_flags(image, deck, nvidia):
    args = b.build_args(
        b.get_variant(image), image_vendor="ublue-os", image_branch="main",
        sha_head_short="abc1234", version_tag="44", version_pretty="Stable (F44)",
    )
    assert args["BUILD_DECK"] == deck
    assert args["BUILD_NVIDIA"] == nvidia


def test_labels_include_required_oci_fields():
    variant = b.get_variant("bazzite")
    labels = b.labels_for(variant, version="44.20260820", sha="deadbeef", kernel_evr="6.0.0")
    for key in (
        "org.opencontainers.image.version",
        "org.opencontainers.image.revision",
        "org.opencontainers.image.created",
        "ostree.bootable",
        "ostree.linux",
    ):
        assert key in labels
    assert labels["ostree.bootable"] == "true"
    assert labels["ostree.linux"] == "6.0.0"


# --- CLI smoke tests ---

def test_cmd_images_is_valid_json(capsys):
    args = b.build_parser().parse_args(["images"])
    assert b.cmd_images(args) == 0
    out = capsys.readouterr().out
    assert json.loads(out) == sorted(b.IMAGES)


def test_cmd_matrix_covers_all_images(capsys):
    args = b.build_parser().parse_args(["matrix"])
    assert b.cmd_matrix(args) == 0
    out = capsys.readouterr().out
    matrix = json.loads(out)
    assert {row["image"] for row in matrix["include"]} == set(b.IMAGES)


# --- run(): stdout is reserved for JSON ---

def test_run_sends_child_stdout_to_stderr(capfd):
    """`podman pull`/`rmi` print IDs to stdout; if those reach our stdout,
    `./build.py rechunk > rechunk.json` stops being valid JSON."""
    b.run(["echo", "sha256:deadbeef"])
    out, err = capfd.readouterr()
    assert "sha256:deadbeef" not in out
    assert "sha256:deadbeef" in err


def test_scratch_dir_prefers_runner_temp(monkeypatch, tmp_path):
    monkeypatch.setenv("RUNNER_TEMP", str(tmp_path))
    assert b.scratch_dir() == str(tmp_path)
    monkeypatch.delenv("RUNNER_TEMP")
    assert b.scratch_dir() is None


# --- cmd_version / resolve --version: one tag for the whole run ---

def test_version_dedups_against_tags_from_every_image(monkeypatch, capsys):
    """A tag taken by only one image still bumps the point release for all."""
    today = b.release_version(ref_name="unstable", fedora_version=FEDORA)
    taken = {"bazzite-deck": {today, f"{today}.1"}}
    monkeypatch.setattr(b, "list_tags", lambda ref: taken.get(ref.rsplit("/", 1)[1], set()))
    args = b.build_parser().parse_args(["version", "--ref-name", "unstable"])
    assert b.cmd_version(args) == 0
    assert json.loads(capsys.readouterr().out) == {"version": f"{today}.2"}


def test_resolve_uses_precomputed_version(capsys):
    args = b.build_parser().parse_args([
        "resolve", "--image", "bazzite-deck", "--ref-name", "unstable",
        "--version", f"unstable-{FEDORA}.20260820.3",
    ])
    assert b.cmd_resolve(args) == 0
    out = json.loads(capsys.readouterr().out)
    assert out["version"] == f"unstable-{FEDORA}.20260820.3"
    assert out["labels"]["org.opencontainers.image.version"] == f"unstable-{FEDORA}.20260820.3"
    assert out["build_args"]["VERSION_TAG"] == f"unstable-{FEDORA}.20260820.3"
    assert out["build_args"]["VERSION_PRETTY"] == f"Unstable (F{FEDORA}.20260820.3, #deadbee)"


def test_resolve_testing_uses_given_version(capsys):
    args = b.build_parser().parse_args([
        "resolve", "--ref-name", "testing", "--version", f"testing-{FEDORA}.20261014",
        "--sha", "c500b43",
    ])
    assert b.cmd_resolve(args) == 0
    out = json.loads(capsys.readouterr().out)
    assert out["build_args"]["VERSION_TAG"] == f"testing-{FEDORA}.20261014"
    assert out["build_args"]["VERSION_PRETTY"] == f"Testing (F{FEDORA}.20261014, #c500b43)"


def test_resolve_rejects_version_for_another_fedora_release():
    args = b.build_parser().parse_args([
        "resolve", "--image", "bazzite", "--version", f"{FEDORA - 1}.20260820",
    ])
    assert b.cmd_resolve(args) == 1


# --- cmd_build: local vs CI resolved-json modes ---

def test_build_local_mode_uses_dev_version(caplog):
    caplog.set_level(logging.INFO, logger="build")
    args = b.build_parser().parse_args(
        ["--dry-run", "build", "--image", "bazzite-deck", "--container-mgr", "podman"]
    )
    assert b.cmd_build(args) == 0
    assert f"--build-arg=VERSION_TAG={FEDORA}.dev" in caplog.text
    assert "--build-arg=IMAGE_BRANCH=local" in caplog.text
    assert "--tag localhost/bazzite-deck:build" in caplog.text
    assert "--secret" not in caplog.text


def test_build_ci_mode_reads_resolved_json(tmp_path, caplog):
    caplog.set_level(logging.INFO, logger="build")
    resolved = {
        "container_target": "bazzite-nvidia",
        "build_args": {"IMAGE_NAME": "bazzite-nvidia", "VERSION_TAG": "44"},
    }
    resolved_path = tmp_path / "resolved.json"
    resolved_path.write_text(json.dumps(resolved))

    args = b.build_parser().parse_args(
        [
            "--dry-run", "build", "--image", "bazzite-nvidia", "--container-mgr", "buildah",
            "--resolved-json", str(resolved_path), "--tag", "raw-img",
            "--secret", "id=GITHUB_TOKEN,env=GITHUB_TOKEN",
        ]
    )
    assert b.cmd_build(args) == 0
    assert "--build-arg=VERSION_TAG=44" in caplog.text
    assert "--secret id=GITHUB_TOKEN,env=GITHUB_TOKEN" in caplog.text
    assert "--tag raw-img" in caplog.text


# --- cmd_rechunk / cmd_sbom / cmd_test: dry-run argument construction ---

def test_rechunk_dry_run_emits_ref(capsys):
    args = b.build_parser().parse_args(["--dry-run", "rechunk"])
    assert b.cmd_rechunk(args) == 0
    out = json.loads(capsys.readouterr().out)
    assert out == {"ref": "containers-storage:localhost/chunked-img"}


def test_rechunk_custom_images_and_max_layers(capsys, caplog):
    caplog.set_level(logging.INFO, logger="build")
    args = b.build_parser().parse_args(
        ["--dry-run", "rechunk", "--raw-image", "custom-raw", "--chunked-image", "localhost/custom-chunked", "--max-layers", "64"]
    )
    assert b.cmd_rechunk(args) == 0
    assert "custom-raw" in caplog.text
    assert "--max-layers 64" in caplog.text
    assert json.loads(capsys.readouterr().out) == {"ref": "containers-storage:localhost/custom-chunked"}


def test_rechunk_verifies_chunkah_image_with_cosign(caplog):
    caplog.set_level(logging.INFO, logger="build")
    args = b.build_parser().parse_args(["--dry-run", "rechunk"])
    assert b.cmd_rechunk(args) == 0
    assert "cosign verify" in caplog.text
    assert "quay.io/coreos/chunkah:latest" in caplog.text
    assert r"--certificate-identity-regexp ^https://github\.com/coreos/chunkah/" in caplog.text


def test_rechunk_uses_custom_chunkah_image(caplog):
    caplog.set_level(logging.INFO, logger="build")
    args = b.build_parser().parse_args(["--dry-run", "rechunk", "--chunkah-image", "quay.io/coreos/chunkah:v1.2.3"])
    assert b.cmd_rechunk(args) == 0
    assert "podman pull quay.io/coreos/chunkah:v1.2.3" in caplog.text


def test_rechunk_strips_stale_labels(caplog):
    caplog.set_level(logging.INFO, logger="build")
    args = b.build_parser().parse_args(["--dry-run", "rechunk"])
    assert b.cmd_rechunk(args) == 0
    for stale in b.STALE_RECHUNK_LABELS:
        assert f"--label {stale}-" in caplog.text


def test_rechunk_includes_labels_from_file(tmp_path, caplog):
    caplog.set_level(logging.INFO, logger="build")
    labels_file = tmp_path / "labels.txt"
    labels_file.write_text("org.opencontainers.image.version=44.20260820\nostree.bootable=true\n")
    args = b.build_parser().parse_args(["--dry-run", "rechunk", "--labels-file", str(labels_file)])
    assert b.cmd_rechunk(args) == 0
    assert "--label org.opencontainers.image.version=44.20260820" in caplog.text
    assert "--label ostree.bootable=true" in caplog.text


def test_rechunk_no_privileged_flag(caplog):
    # chunkah doesn't need --privileged -- assert it's genuinely gone,
    # not just unmentioned.
    caplog.set_level(logging.INFO, logger="build")
    args = b.build_parser().parse_args(["--dry-run", "rechunk"])
    assert b.cmd_rechunk(args) == 0
    assert "--privileged" not in caplog.text


def test_sbom_scans_mounted_image_without_exporting(capsys, caplog):
    caplog.set_level(logging.INFO, logger="build")
    args = b.build_parser().parse_args(
        ["--dry-run", "sbom", "--image", "bazzite-deck", "--chunked-image", "localhost/custom-chunked",
         "--version-tag", "45.20261018", "--syft-cmd", "/opt/syft"]
    )
    assert b.cmd_sbom(args) == 0
    assert "buildah unshare" in caplog.text
    assert "bash localhost/custom-chunked /opt/syft bazzite-deck-45.20261018 " in caplog.text
    assert "export" not in caplog.text
    assert json.loads(capsys.readouterr().out)["sbom"].endswith("/sbom.json")


def test_test_dry_run_invokes_dgoss(caplog):
    caplog.set_level(logging.INFO, logger="build")
    args = b.build_parser().parse_args(["--dry-run", "test", "--ref", "containers-storage:localhost/chunked-img"])
    assert b.cmd_test(args) == 0
    assert "tests/dgoss/dgoss-tests.sh tests/dgoss/tests.d containers-storage:localhost/chunked-img" in caplog.text


# --- cmd_push / cmd_sign / cmd_sbom_attach: dry-run argument construction ---

def test_push_pushes_twice_and_copies_all_alias_tags(caplog):
    caplog.set_level(logging.INFO, logger="build")
    args = b.build_parser().parse_args(
        [
            "--dry-run", "push",
            "--output-image", "ghcr.io/testuser/bazzite-deck",
            "--version", "44.20260820",
            "--alias-tags", "stable-44.20260820 latest stable stable-44",
            "--rechunk-ref", "containers-storage:localhost/chunked-img",
        ]
    )
    assert b.cmd_push(args) == 0
    assert caplog.text.count("podman push") == 2
    assert caplog.text.count(" localhost/chunked-img docker://") == 2
    assert "containers-storage:" not in caplog.text  # rechunk-ref prefix stripped
    for tag in ("stable-44.20260820", "latest", "stable", "stable-44"):
        assert f"docker://ghcr.io/testuser/bazzite-deck:{tag}" in caplog.text


def test_push_dry_run_emits_digest(capsys):
    args = b.build_parser().parse_args(
        [
            "--dry-run", "push",
            "--output-image", "ghcr.io/testuser/bazzite-deck",
            "--version", "44.20260820",
            "--alias-tags", "latest",
            "--rechunk-ref", "containers-storage:localhost/chunked-img",
        ]
    )
    assert b.cmd_push(args) == 0
    assert json.loads(capsys.readouterr().out) == {"digest": "sha256:dryrun"}


def test_push_writes_step_summary(tmp_path, capsys):
    summary_file = tmp_path / "summary.md"
    args = b.build_parser().parse_args(
        [
            "--dry-run", "push",
            "--output-image", "ghcr.io/testuser/bazzite-deck",
            "--version", "44.20260820",
            "--alias-tags", "latest",
            "--rechunk-ref", "containers-storage:localhost/chunked-img",
            "--summary-file", str(summary_file),
        ]
    )
    assert b.cmd_push(args) == 0
    text = summary_file.read_text()
    assert "# Push to GHCR result" in text
    assert "ghcr.io/testuser/bazzite-deck:44.20260820" in text


def test_sign_uses_cosign_private_key_env(caplog):
    caplog.set_level(logging.INFO, logger="build")
    args = b.build_parser().parse_args(["--dry-run", "sign", "--ref", "ghcr.io/testuser/bazzite-deck@sha256:abc"])
    assert b.cmd_sign(args) == 0
    assert "env://COSIGN_PRIVATE_KEY" in caplog.text
    # Key-based .sig signatures, which `cosign verify --new-bundle-format=false` checks.
    assert "--new-bundle-format=false --use-signing-config=false" in caplog.text
    assert "ghcr.io/testuser/bazzite-deck@sha256:abc" in caplog.text


def test_sbom_attach_dry_run_emits_placeholder_digest(capsys):
    args = b.build_parser().parse_args(
        ["--dry-run", "sbom-attach", "--image", "ghcr.io/testuser/bazzite-deck", "--digest", "sha256:abc", "--sbom", "/tmp/sbom.json"]
    )
    assert b.cmd_sbom_attach(args) == 0
    assert json.loads(capsys.readouterr().out) == {"sbom_digest": "sha256:dryrun-sbom"}


def test_resolve_bakes_image_vendor_into_build_args(capsys):
    """CI passes the lowercased repo owner, so fork builds identify as the fork."""
    args = b.build_parser().parse_args([
        "resolve", "--image", "bazzite", "--version", f"{FEDORA}.20260820",
        "--image-vendor", "some-fork",
    ])
    assert b.cmd_resolve(args) == 0
    assert json.loads(capsys.readouterr().out)["build_args"]["IMAGE_VENDOR"] == "some-fork"


def test_sbom_attach_passes_relative_path_from_sbom_dir(caplog):
    """oras rejects absolute file paths, so the SBOM is attached by bare name
    from its own directory -- this failed every image on the first push run."""
    caplog.set_level(logging.INFO, logger="build")
    b.main([
        "--dry-run", "sbom-attach", "--image", "ghcr.io/x/bazzite",
        "--digest", "sha256:abc", "--sbom", "/tmp/sbom-xyz/sbom.json",
    ])
    line = next(r.getMessage() for r in caplog.records if "oras attach" in r.getMessage())
    assert line.startswith("+ (cd /tmp/sbom-xyz && oras attach")
    assert line.endswith(" sbom.json)")
    assert "/tmp/sbom-xyz/sbom.json" not in line


def test_sbom_packages_keeps_rpms_and_prefers_epoch_version():
    sbom = {"artifacts": [
        {"type": "rpm", "name": "mesa-filesystem", "version": "26.2.4-1.fc45"},
        {"type": "rpm", "name": "mesa-filesystem", "version": "1:26.2.4-1.fc45"},
        {"type": "rpm", "name": "mesa-filesystem", "version": "26.2.4-1.fc45"},
        {"type": "python", "name": "requests", "version": "2.32.0"},
        {"type": "rpm", "name": "kernel-core"},
    ]}
    assert b.sbom_packages(sbom) == {"mesa-filesystem": "1:26.2.4-1.fc45"}


def test_cmd_packages_writes_versioned_file_next_to_sbom(tmp_path, capsys):
    sbom = tmp_path / "sbom.json"
    sbom.write_text(json.dumps({"artifacts": [{"type": "rpm", "name": "steam", "version": "1.0.0.87-5.fc45"}]}))
    version = f"unstable-{FEDORA}.20261021.3"
    assert b.main(["packages", "--image", "bazzite-deck", "--sbom", str(sbom), "--version", version]) == 0
    out = json.loads(capsys.readouterr().out)
    assert out == {"packages": str(tmp_path / "packages-bazzite-deck.json")}
    assert json.loads((tmp_path / "packages-bazzite-deck.json").read_text()) == {
        "image": "bazzite-deck", "version": version, "packages": {"steam": "1.0.0.87-5.fc45"},
    }


def fake_run_with_stdout(monkeypatch, stdout):
    calls = []

    def fake_run(cmd, **kwargs):
        calls.append(" ".join(cmd))
        return subprocess.CompletedProcess(cmd, 0, stdout=stdout, stderr="")

    monkeypatch.setattr(b, "run", fake_run)
    return calls


def test_shell_builds_first_when_image_is_missing(monkeypatch):
    calls = fake_run_with_stdout(monkeypatch, stdout="")
    assert b.main(["shell", "--image", "bazzite-deck", "--container-mgr", "podman"]) == 0
    assert calls[1].startswith("podman build ")
    assert "--tag localhost/bazzite-deck:build" in calls[1]
    assert calls[2] == "podman run -it --rm localhost/bazzite-deck:build /usr/bin/bash"


def test_shell_passes_build_options_to_its_build(monkeypatch):
    calls = fake_run_with_stdout(monkeypatch, stdout="")
    assert b.main([
        "shell", "--image", "bazzite", "--container-mgr", "podman",
        "--secret", "id=GITHUB_TOKEN,env=GITHUB_TOKEN", "--tag", "localhost/custom:dev",
    ]) == 0
    assert "--secret id=GITHUB_TOKEN,env=GITHUB_TOKEN" in calls[1]
    assert "--tag localhost/custom:dev" in calls[1]
    assert calls[2] == "podman run -it --rm localhost/custom:dev /usr/bin/bash"


def test_shell_skips_build_when_image_exists(monkeypatch):
    calls = fake_run_with_stdout(monkeypatch, stdout="abc123\n")
    assert b.main(["shell", "--image", "bazzite", "--container-mgr", "podman"]) == 0
    assert not any(call.startswith("podman build ") for call in calls)
    assert calls[-1] == "podman run -it --rm localhost/bazzite:build /usr/bin/bash"
