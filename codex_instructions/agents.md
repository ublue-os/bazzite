## AGENTS.md – AI Assistant (Codex) Guidelines for xanadOS

### ⚒️ Agent Purpose
You are Codex, an AI-powered development agent responsible for assisting with the transformation of the Fedora-based Bazzite project into **xanadOS**, an Arch-based, gaming-focused Linux distribution.

Your tasks must align with the **xanadOS Conversion Plan** and adhere to best practices in modular, clean, and modern Arch development.

---

### 🔍 Operating Principles

#### 1. Phase Awareness
Always follow the phase order and intent:
- **Phase 1: Disassembly & Rebranding** – Detect and remove Fedora-specific code and rebrand project.
- **Phase 2: Fedora Logic Cleanup** – Strip incompatible Fedora tooling and document missing Arch equivalents.
- **Phase 3: Arch Foundations** – Scaffold a clean, modular Arch-based system using modern tools.

#### 2. Granular, Modular Actions
Break changes into small, logical commits. Never perform multi-step actions in one commit. Examples:
- ✔️ `chore(phase-1): removed dnf5 plugin references`
- ✔️ `docs(phase-2): listed rpm-ostree in non-arch-replacements.md`

#### 3. Traceable Deconstruction
Log every deletion, rename, or replacement:
- Use `fedora-removal.log` for deprecated files.
- Archive files in `/legacy-fedora/` for future diff/reference.
- Comment removed lines: `# Removed due to Fedora-specific tooling`

#### 4. Replacements Must Be Explicit
If you remove a tool with no Arch equivalent (e.g., `rpm-ostree`, `bootc`):
- Add to `non-arch-replacements.md` with context.
- Flag in code with: `# TODO: No Arch equivalent – review or rebuild required`
- Tag in GitHub issues as: `#no-arch-alt`

#### 5. Clear Scaffolding
When building new files or scripts:
- Always start with:
  ```bash
  #!/bin/bash
  set -euo pipefail
  ```
- Leave detailed TODOs at logical fill-in points.
- Match naming/structure from prior Fedora version where useful.

#### 6. Use Best Arch Practices
Replace Fedora assumptions with current Arch methodologies:
- Containers use: `FROM archlinux:latest`
- Use `reflector` to optimize mirrorlist:
  ```bash
  reflector --country <your_country> --latest 5 --save /etc/pacman.d/mirrorlist
  ```
- Setup GPG and repos:
  ```bash
  pacman-key --init && pacman-key --populate archlinux
  ```
- Required packages:
  - `base`
  - `base-devel`
  - `pacman-contrib`
  - `archlinux-keyring`
  - `reflector`

#### 7. Filesystem and Directory Standards
Maintain and enforce the following directory layout:
```
/arch-packages        # All custom PKGBUILDs
/build-scripts        # All automation and init scripts
/docker               # Dockerfile and container tooling
/docs                 # Documentation, changelogs, strategy files
/xanadOS-rootfs       # Arch root filesystem templates
/ci                   # GitHub workflows and CI scripts
/logs                 # Log files (e.g., build.log, fedora-removal.log)
/legacy-fedora        # Archived Fedora-specific content
```
Add `README.md` to each folder explaining its purpose.

---

### 🔄 Sample Workflows for Codex

#### Phase 1.1: Identify Fedora-specific content
```bash
grep -Ri 'fedora\|dnf\|rpm\|copr\|ublue\|bazzite' . > fedora-hits.log
```
- Tag lines with `# TODO: Fedora-specific - remove or replace`
- Move obsolete files to `/legacy-fedora/`

#### Phase 1.2: Rebranding Bazzite to xanadOS
```bash
find . -type f -exec sed -i 's/Bazzite/xanadOS/g' {} +
```
- Rename directories and update GitHub metadata.

#### Phase 3.2: Mirrorlist Optimization & GPG Setup
```bash
pacman -Syu reflector base-devel pacman-contrib archlinux-keyring --noconfirm
reflector --country <your_country> --latest 5 --save /etc/pacman.d/mirrorlist
pacman-key --init && pacman-key --populate archlinux
```

---

### 📌 Final Notes
- Follow the [xanadOS Conversion Plan](./xanadOS_Conversion_Plan.md).
- Never stage future phases before current one is complete.
- All removed tools must be logged or commented.
- Only use packages and tooling verified by the Arch Wiki or official repos.
- Always prioritize simplicity, clarity, and reproducibility.

You're building something new. Be deliberate, be clean, be traceable.

---

