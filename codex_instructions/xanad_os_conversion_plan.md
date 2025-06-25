## xanadOS Conversion Plan – Full Task Breakdown for Codex

### Phase 1 – Disassembly & Rebranding

#### Step 1.1 – Identify All Fedora-Specific Packages, Scripts, and Tools

- **Purpose**: Detect all references to Fedora technology, packages, and tooling to ensure they are isolated or flagged for removal.
- **Instructions**:
  - Search for keywords such as `dnf`, `dnf5`, `rpm-ostree`, `copr`, `.spec`, `FEDORA_VERSION`, `fedora`, `ublue`, and `kinoite` in Dockerfiles, scripts, and configuration files.
  - Use a catch-all command like:
    ```bash
    grep -Ri 'fedora\|dnf\|rpm\|copr\|ublue\|bazzite' . > fedora-hits.log
    ```
  - Add inline comments such as `# TODO: Fedora-specific - remove or replace`.
  - Optionally move these lines or files into a temporary `legacy-fedora/` directory for archiving and future reference.

#### Step 1.2 – Replace All "Bazzite" References with "xanadOS"

- **Purpose**: Rebrand the entire system to reflect the new project identity.
- **Instructions**:
  - Perform a project-wide search-and-replace of the term "Bazzite" with "xanadOS" in:
    - `README.md`, code comments, build metadata, and scripts.
    - GitHub Actions workflows (e.g. `build.yml`)
    - Docker image names, titles, and labels
  - Rename any filenames or folders that contain the word "bazzite".
  - Update commit messages and GitHub repository settings (like the description).

#### Step 1.3 – Remove Fedora-Based Files That Are No Longer Usable

- **Purpose**: Clean the project from dependencies on Fedora’s packaging and update mechanisms.
- **Instructions**:
  - Delete any file that directly requires `dnf`, `.spec` files, or Fedora repositories.
  - These include:
    - `spec_files/`
    - `dnf-plugins` install scripts
    - References to RPM Fusion or COPR repositories
  - Document each removed file or component in `fedora-removal.log` with a brief explanation.
  - Optionally archive these files in the `legacy-fedora/` directory for traceability.

### Phase 2 – Fedora Logic Cleanup

#### Step 2.1 – Strip rpm-ostree, dnf5, spec_files, and Fedora Repos

- **Purpose**: Eliminate remaining logic that ties the system to Fedora's update and package model.
- **Instructions**:
  - Remove all `dnf5` commands from scripts like `build.sh`, `finalize.sh`, etc.
  - Remove `rpm-ostree` specific logic or installation hooks.
  - Eliminate `.repo` files pointing to Fedora repositories.
  - Confirm that Dockerfiles and container builds no longer inherit from any Fedora base image.

#### Step 2.2 – Leave TODOs for Tools Without Arch Equivalents

- **Purpose**: Clearly mark components that require further design or replacement.
- **Instructions**:
  - If you encounter a Fedora-specific component with no known Arch replacement (e.g. `rpm-ostree`, `bootc`):
    - Add a comment like: `# TODO: No Arch equivalent – review or rebuild required`.
    - Optionally list these components in a `non-arch-replacements.md` file with context and brainstormed solutions.
    - Use GitHub issue tags like `#no-arch-alt` to track unresolved components.

### Phase 3 – Arch Foundations

#### Step 3.1 – Add Arch Base Container or Root System

- **Purpose**: Establish the fundamental Arch Linux base the new distro will use.
- **Instructions**:
  - Choose your build method:
    - **Container-based**: use `FROM archlinux:latest` in Dockerfile.
    - **ISO/live image**: use `archiso` and `airootfs` to customize.
    - **Bare rootfs**: use `pacstrap` to build a base filesystem.
  - Confirm pacman is functional and `/etc/pacman.d/mirrorlist` is present.
  - Reference: https://github.com/archlinux/archlinux-docker

#### Step 3.2 – Setup pacman, base-devel, and Configuration

- **Purpose**: Prepare essential tooling and configs for package management.
- **Instructions**:
  - Install:
    - `base`, `base-devel`, `pacman-contrib`, `archlinux-keyring`, `reflector`
  - Use `reflector` to optimize the mirrorlist:
    ```bash
    reflector --country <your_country> --latest 5 --save /etc/pacman.d/mirrorlist
    ```
  - Create or modify `/etc/pacman.conf` to:
    - Enable multilib if needed
    - Add placeholders for custom repos under `[xanados-custom]`
  - Generate new pacman GPG keyring using `pacman-key --init && pacman-key --populate archlinux`

#### Step 3.3 – Create Empty Build and Init Scripts

- **Purpose**: Scaffold placeholders for later Codex-driven population.
- **Instructions**:
  - Create new versions of key build system scripts:
    - `build.sh`, `initramfs.sh`, `finalize.sh`, etc.
    - Each script should include a shebang (e.g. `#!/bin/bash`) and `set -euo pipefail` for safe scripting.
    - Insert `# TODO` markers where logic will be added later.
  - Preserve structure and order from previous Fedora versions, but without internal logic.
  - Place scripts in `/build-scripts/` or `/scripts/` as appropriate.

#### Step 3.4 – Setup Folder Scaffold

- **Purpose**: Organize the repository for clear, modular development.
- **Instructions**:
  - Create the following directories:
    ```
    /arch-packages        # All custom PKGBUILDs
    /build-scripts        # All automation and init scripts
    /docker               # Dockerfile and container tooling
    /docs                 # Documentation, changelogs, strategy files
    /xanadOS-rootfs       # Arch root filesystem templates
    /ci                   # GitHub workflows and CI scripts
    /logs                 # Log files (e.g., build.log, fedora-removal.log)
    ```
  - Include README files in each directory explaining their purpose.
  - Ensure folder structure supports modular contribution and CI scripting later.

---

This document is designed to guide Codex through the orderly deconstruction of Fedora-specific tooling and reconstruction of an Arch-based equivalent. Each step is clearly modular, self-contained, and documented for maximum clarity, resilience, and AI-assisted development.

