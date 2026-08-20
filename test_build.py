"""Golden tests for build.py.

Run with: python3 -m pytest test_build.py -v

These lock down the variant table and version/tag logic against what the
old build.yml bash derived, so a future edit can't silently change what
gets published. See build.py's IMAGES table comment and the plan's
verification section for context.
"""

import json
import logging
from datetime import datetime, timezone

import pytest

import build as b

# Hand-derived from build.yml's "Define base variables" step (lines 104-160)
# and the matrix `include` overrides (lines 71-82), read directly off the
# workflow file rather than off build.py, so this can't just echo a bug back.
EXPECTED_VARIANTS = {
    "bazzite": {
        "base_image_name": "kinoite", "container_target": "bazzite",
        "nvidia_base": "bazzite", "nvidia_flavor": "nvidia-lts", "install_nvidia": False,
        "kernel_flavor": "ogc", "kernel_version": "7.2.0-ogc3.1.fc44",
    },
    "bazzite-gnome": {
        "base_image_name": "silverblue", "container_target": "bazzite",
        "nvidia_base": "bazzite", "nvidia_flavor": "nvidia-lts", "install_nvidia": False,
        "kernel_flavor": "ogc", "kernel_version": "7.2.0-ogc3.1.fc44",
    },
    "bazzite-deck": {
        "base_image_name": "kinoite", "container_target": "bazzite-deck",
        "nvidia_base": "bazzite-deck", "nvidia_flavor": "nvidia-lts", "install_nvidia": False,
        "kernel_flavor": "ogc", "kernel_version": "7.2.0-ogc3.1.fc44",
    },
    "bazzite-deck-gnome": {
        "base_image_name": "silverblue", "container_target": "bazzite-deck",
        "nvidia_base": "bazzite-deck", "nvidia_flavor": "nvidia-lts", "install_nvidia": False,
        "kernel_flavor": "ogc", "kernel_version": "7.2.0-ogc3.1.fc44",
    },
    "bazzite-deck-nvidia": {
        "base_image_name": "kinoite", "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite-deck", "nvidia_flavor": "nvidia-open", "install_nvidia": True,
        "kernel_flavor": "ogc", "kernel_version": "7.2.0-ogc3.1.fc44",
    },
    "bazzite-deck-nvidia-gnome": {
        "base_image_name": "silverblue", "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite-deck", "nvidia_flavor": "nvidia-open", "install_nvidia": True,
        "kernel_flavor": "ogc", "kernel_version": "7.2.0-ogc3.1.fc44",
    },
    "bazzite-nvidia": {
        "base_image_name": "kinoite", "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite", "nvidia_flavor": "nvidia-lts", "install_nvidia": True,
        "kernel_flavor": "ogc-lts", "kernel_version": "6.18.44-ogc1.1.fc44",
    },
    "bazzite-gnome-nvidia": {
        "base_image_name": "silverblue", "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite", "nvidia_flavor": "nvidia-lts", "install_nvidia": True,
        "kernel_flavor": "ogc-lts", "kernel_version": "6.18.44-ogc1.1.fc44",
    },
    "bazzite-nvidia-open": {
        "base_image_name": "kinoite", "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite", "nvidia_flavor": "nvidia-open", "install_nvidia": True,
        "kernel_flavor": "ogc", "kernel_version": "7.2.0-ogc3.1.fc44",
    },
    "bazzite-gnome-nvidia-open": {
        "base_image_name": "silverblue", "container_target": "bazzite-nvidia",
        "nvidia_base": "bazzite", "nvidia_flavor": "nvidia-open", "install_nvidia": True,
        "kernel_flavor": "ogc", "kernel_version": "7.2.0-ogc3.1.fc44",
    },
}


def test_images_table_matches_ci_matrix():
    assert set(b.IMAGES) == set(EXPECTED_VARIANTS)


@pytest.mark.parametrize("image", sorted(EXPECTED_VARIANTS))
def test_variant_matches_ci_derivation(image):
    variant = b.get_variant(image)
    expected = EXPECTED_VARIANTS[image]
    assert variant.base_image_name == expected["base_image_name"]
    assert variant.container_target == expected["container_target"]
    assert variant.nvidia_base == expected["nvidia_base"]
    assert variant.nvidia_flavor == expected["nvidia_flavor"]
    assert variant.install_nvidia == expected["install_nvidia"]
    assert variant.kernel_flavor == expected["kernel_flavor"]
    assert variant.kernel_version == expected["kernel_version"]
    assert variant.fedora_version == 44
    assert variant.base_image == f"ghcr.io/ublue-os/{expected['base_image_name']}-main:44"


def test_unknown_image_raises_with_valid_list():
    with pytest.raises(ValueError, match="unknown image"):
        b.get_variant("bazzite-does-not-exist")


# --- resolve_source_version: build.yml "Pull Images and find versions" (187-223) ---

def test_source_version_stable():
    version, pretty = b.resolve_source_version(
        ref_name="main", upstream_tag="44", sha_short="abc1234", fedora_version=44,
    )
    assert version == "44"
    assert pretty == "Stable (F44)"


def test_source_version_unstable():
    version, pretty = b.resolve_source_version(
        ref_name="unstable", upstream_tag="44", sha_short="abc1234", fedora_version=44,
    )
    assert version == "unstable-44"
    assert pretty == "Unstable (F44, #abc1234)"


def test_source_version_testing():
    version, pretty = b.resolve_source_version(
        ref_name="testing", upstream_tag="44", sha_short="abc1234", fedora_version=44,
    )
    assert version == "testing-44"
    assert pretty == "Testing (F44, #abc1234)"


def test_source_version_pr_number_takes_priority_over_ref():
    # build.yml checks pr_number first regardless of ref_name (lines 208-210)
    version, pretty = b.resolve_source_version(
        ref_name="unstable", upstream_tag="44", sha_short="abc1234",
        fedora_version=44, pr_number="42",
    )
    assert version == "pr-44-42"
    assert pretty == "PR (42, 44)"


def test_strip_trailing_zero():
    # Mirrors bash's ${UPSTREAM_TAG%\.[0-9]}: strips any trailing ".<digit>",
    # not just ".0" -- that's the actual (slightly loose) upstream behavior.
    assert b.strip_trailing_zero("44.0") == "44"
    assert b.strip_trailing_zero("44.1") == "44"
    assert b.strip_trailing_zero("44") == "44"


# --- release_version / dedup_version: build.yml "Apply Labels" (325-386) ---

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


# --- alias_tags: build.yml "Generate tags" (463-482) ---

def test_alias_tags_stable():
    tags = b.alias_tags(ref_name="main", version="44.20260820", fedora_version=44)
    assert tags == ["stable-44.20260820", "latest", "stable", "stable-44"]


def test_alias_tags_unstable():
    tags = b.alias_tags(ref_name="unstable", version="unstable-44.20260820", fedora_version=44)
    assert tags == ["unstable", "unstable-44"]


def test_alias_tags_testing():
    tags = b.alias_tags(ref_name="testing", version="testing-44.20260820", fedora_version=44)
    assert tags == ["testing", "testing-44"]


# --- build_args: build.yml "Prepare build args file" (242-259) ---

def test_build_args_field_set_matches_ci():
    variant = b.get_variant("bazzite-deck-nvidia")
    args = b.build_args(
        variant, image_vendor="ublue-os", image_branch="main",
        sha_head_short="abc1234", version_tag="44", version_pretty="Stable (F44)",
    )
    # The exact 14 build-args CI writes to build_args.txt -- deliberately
    # excludes SOURCE_IMAGE, which just_scripts/build-image.sh sends but
    # which isn't a real ARG in the Containerfile (silently ignored there).
    assert set(args) == {
        "BASE_IMAGE_NAME", "FEDORA_VERSION", "BASE_IMAGE", "IMAGE_NAME",
        "IMAGE_VENDOR", "IMAGE_BRANCH", "KERNEL_FLAVOR", "KERNEL_VERSION",
        "NVIDIA_FLAVOR", "NVIDIA_BASE", "SHA_HEAD_SHORT", "VERSION_TAG",
        "VERSION_PRETTY", "ARCH",
    }
    assert args["SHA_HEAD_SHORT"] == "abc1234"  # never empty, unlike build.yml:255 today


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


# --- cmd_build: local vs CI resolved-json modes ---

def test_build_local_mode_uses_dev_version(caplog):
    caplog.set_level(logging.INFO, logger="build")
    args = b.build_parser().parse_args(
        ["--dry-run", "build", "--image", "bazzite-deck", "--container-mgr", "podman"]
    )
    assert b.cmd_build(args) == 0
    assert "--build-arg=VERSION_TAG=44.dev" in caplog.text
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
    assert "--target bazzite-nvidia" in caplog.text
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
    assert "--max-layers=64" in caplog.text
    assert json.loads(capsys.readouterr().out) == {"ref": "containers-storage:localhost/custom-chunked"}


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
    assert caplog.text.count("localhost/chunked-img") == 2  # rechunk-ref prefix stripped
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
    assert "ghcr.io/testuser/bazzite-deck@sha256:abc" in caplog.text


def test_sbom_attach_dry_run_emits_placeholder_digest(capsys):
    args = b.build_parser().parse_args(
        ["--dry-run", "sbom-attach", "--image", "ghcr.io/testuser/bazzite-deck", "--digest", "sha256:abc", "--sbom", "/tmp/sbom.json"]
    )
    assert b.cmd_sbom_attach(args) == 0
    assert json.loads(capsys.readouterr().out) == {"sbom_digest": "sha256:dryrun-sbom"}
