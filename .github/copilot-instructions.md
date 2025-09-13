# Bazzite Operating System

Bazzite is a containerized Linux gaming distribution built on Fedora Atomic Desktops using cloud native
technology. It provides optimized gaming experiences for desktop computers, Steam Deck, and other handheld
devices with features like HDR support, expanded hardware compatibility, and gaming-focused optimizations.

Always reference these instructions first and fallback to search or bash commands only when you encounter
unexpected information that does not match the info here.

## Working Effectively

### Prerequisites and Setup

- Install required tools:
  - `sudo apt update && sudo apt install -y just` (on Ubuntu/Debian)
  - Docker or Podman for container builds
  - Git for repository management

- Bootstrap the repository:
  - `git clone https://github.com/ublue-os/bazzite.git`
  - `cd bazzite`

### Build System Overview

- **Primary build tool**: `just` (command runner similar to make)
- **Container builds**: Uses Docker/Podman with `Containerfile` (equivalent to Dockerfile)
- **Build infrastructure**: Requires specific akmods kernel images only available in CI environment
- **Build targets**: `bazzite` (desktop), `bazzite-deck` (Steam Deck), `bazzite-nvidia` (NVIDIA variants)

### Validation Commands (NEVER CANCEL - Complete Quickly)

- `just --list` -- Lists all available commands (< 1 second)
- `just just-check` -- Validates Just syntax across all files (< 30 seconds). EXPECTED: Shows warnings
  about unknown attributes but succeeds overall
- `just list-images` -- Shows local container images (< 5 seconds)
- `just clean-images` -- Cleanup local images (< 30 seconds)

### Build Commands (WARNING: REQUIRE CI ENVIRONMENT)

**CRITICAL**: Full builds CANNOT be completed in local development environment due to missing akmods
kernel images. These commands will fail outside CI:

- `just build <target>` -- Builds container images. FAILS: Requires ghcr.io/ublue-os/akmods:bazzite-* images
- `just build-iso <target>` -- Builds ISO images. FAILS: Depends on successful container builds
- `just run-container <target>` -- Runs built containers. FAILS: Depends on successful builds

### Branch Name Constraints

**CRITICAL**: Git branch names cannot contain "/" characters as they break Docker container tags.

**Proper Branch Naming Convention:**

- `feat-<description>` - New features (e.g., `feat-hdr-support`, `feat-mesa-update`)
- `fix-<issue-number>` - Bug fixes (e.g., `fix-3185`, `fix-audio-crackling`)
- `docs-<description>` - Documentation updates (e.g., `docs-install-guide`)
- `refactor-<component>` - Code refactoring (e.g., `refactor-just-scripts`)
- `test-<description>` - Testing improvements (e.g., `test-ci-validation`)

**Examples:**

- ✅ GOOD: `feat-gamescope-hdr`, `fix-3185`, `docs-copilot-instructions`, `refactor-containerfile`
- ❌ BAD: `feature/name`, `fix/123`, `copilot/fix-3185`, `feat_underscore_name`
- If using bad branch name, create new branch: `git checkout -b fix-3185`

### CI Build Information (From .github/workflows/build.yml)

- **Build Environment**: Ubuntu 24.04 with specialized container storage
- **Build Matrix**: Multiple combinations of base images, targets, and flavors
- **Kernel Versions**: Specific bazzite kernel versions (e.g., 6.16.4-107.bazzite.fc42.x86_64)
- **Build Steps**: Image pulls, buildah builds, rechunking, signing, pushing to GHCR
- **Build Dependencies**: Base images, akmods images, kernel images from ublue-os registry

### Code Quality Standards

**Codacy Formatting Requirements:**

- **Line Length**: Maximum 120 characters per line
- **List Spacing**: Blank lines required between different list groups
- **Header Spacing**: Blank line required after section headers before content
- **File Termination**: Files must end with a newline character
- **No Trailing Whitespace**: Remove spaces at end of lines
- Run validation: Files are automatically checked in CI for compliance

### Core Component Repositories

**Bazzite Organization Dependencies:**
Many core Bazzite components are maintained in separate repositories at <https://github.com/bazzite-org>:

- **mesa** - Custom Mesa graphics drivers with gaming optimizations
- **gamescope-session-steam** - Gamescope session management for Steam
- **kernel-bazzite** - Custom kernel with gaming and handheld optimizations  
- **jupiter-hw-support** - Steam Deck hardware support packages
- **steamdeck-dsp** - Audio processing for Steam Deck
- **powerbuttond** - Power button daemon for handhelds

**When to Reference:**

- Graphics/Mesa issues: Check `bazzite-org/mesa` for driver-specific changes
- Kernel problems: Review `bazzite-org/kernel-bazzite` for patches and configs
- Steam Deck issues: Look at `bazzite-org/jupiter-hw-support` and related repos
- Audio problems: Check `bazzite-org/steamdeck-dsp` for audio configurations
- Session management: Review `bazzite-org/gamescope-session-steam` for session handling

## Validation

- **Syntax Validation**: Always run `just just-check` before submitting changes (30 seconds, NEVER CANCEL)
- **Code Quality**: Follow Codacy formatting requirements (see Code Quality Standards above)
- **Local Development**: Focus on configuration files, scripts, and system files that don't require full builds
- **CI Validation**: Full builds and tests run automatically in GitHub Actions (60+ minutes, NEVER CANCEL)
- **Manual Testing**: Image testing occurs in CI environment with specialized infrastructure
- **Development Testing Scenarios**:
  - Edit configuration files in `system_files/`
  - Modify Just scripts and validate with `just just-check`
  - Test repository setup on fresh clones
  - Validate CI workflow changes through PR process

## Common Tasks

### Repository Structure

```
.
├── Justfile                    # Main build automation
├── Containerfile              # Container build definition
├── just_scripts/              # Build helper scripts
├── build_files/               # Build utilities and scripts
├── system_files/              # System configuration files
│   ├── desktop/               # Desktop variant configurations
│   ├── deck/                  # Steam Deck variant configurations
│   └── nvidia/                # NVIDIA variant configurations
├── .github/workflows/         # CI/CD pipelines
├── installer/                 # Installation related files
└── spec_files/               # RPM spec files for custom packages
```

### Key Development Files

- **Build Configuration**: `Justfile`, `Containerfile`, `just_scripts/*.sh`
- **System Configuration**: Files in `system_files/` for different variants
- **CI/CD**: `.github/workflows/build.yml` for container builds, `build_iso.yml` for ISO builds
- **Package Specs**: `spec_files/` contains RPM specifications for custom packages

### Available Just Commands (from `just --list`)

```
build target="" image=""           # Build image (CI only)
build-iso-git target="" image=""   # Build ISO using ISO Builder Git Head (CI only)
build-iso-release target="" image="" # Build ISO (CI only)
clean-images                       # Clean Images
clean-isos                         # Clean ISOs
just-check                         # Check Just Syntax - ALWAYS RUN THIS
list-images                        # List Images
run-container target="" image=""   # Run Container (CI only)
run-iso target="" image=""         # Run ISO (CI only)
```

### Development Workflow

1. **Setup**: Clone repository and install `just`
   - `git clone https://github.com/ublue-os/bazzite.git && cd bazzite`
   - `sudo apt update && sudo apt install -y just` (Ubuntu/Debian)

2. **Branch**: Create appropriately named branch (no "/" characters)
   - ✅ `git checkout -b fix-issue-name`
   - ❌ Avoid: `git checkout -b feature/name`

3. **Edit**: Modify configuration files, system files, or build scripts
   - Focus on files in `system_files/`, `just_scripts/`, `.github/workflows/`

4. **Validate**: Run `just just-check` to verify syntax (< 30 seconds)
   - EXPECTED: May show warnings about "Unknown attribute `group`" but should succeed

5. **Test**: CI automatically builds and tests on push/PR (60+ minutes, NEVER CANCEL)

6. **Review**: Use PR process for code review and validation

### CI Build Timing (From Workflow Analysis)

- **NEVER CANCEL**: CI builds can take 60+ minutes for full matrix
- **Image Build**: Individual image builds typically 30-45 minutes
- **ISO Build**: ISO generation can take 45-60 minutes
- **Full Matrix**: Complete CI run with all variants: 120+ minutes
- **Image Pull**: Base image downloads: 5-10 minutes each
- **Container Registry**: Push operations: 10-20 minutes

### Common Issues and Solutions

- **Build Failures**: Usually related to missing base images or network issues in CI
- **Syntax Errors**: Run `just just-check` to identify Just syntax problems
- **Branch Name Issues**: Ensure branch names are Docker tag compatible (no special characters)
- **Local Testing**: Most development can be done by editing configuration files without full builds

### Build Variants and Images

- **Desktop Variants**: `bazzite` (KDE), `bazzite-gnome` (GNOME)
- **Deck Variants**: `bazzite-deck` (KDE), `bazzite-deck-gnome` (GNOME)
- **NVIDIA Variants**: Add `-nvidia` suffix for proprietary driver versions
- **Specialized**: `bazzite-ally` (ASUS), surface editions available

### File Categories by Build Impact

- **Safe to Edit Locally**: System configuration files, Just scripts, documentation
- **Requires CI Testing**: Containerfile changes, kernel configurations, package additions
- **High Impact**: Base image changes, kernel version updates, major package modifications

### ujust Commands (Available in Built Images)

The built images include numerous `ujust` commands for user configuration:

- Gaming: `ujust install-resolve`, `ujust install-openrazer`
- System: `ujust enable-rmlint`, `ujust setup-virtualization`
- Hardware: `ujust disable-bios-updates`, `ujust setup-sunshine`
- Network: `ujust toggle-wol`

**Note**: These commands are only available in built and running Bazzite systems, not during development.

## Common Commands Output

The following are outputs from frequently run commands. Reference them instead of viewing, searching,
or running bash commands to save time.

### Repository Root Structure

```bash
$ ls -la
total 648
drwxr-xr-x 14 runner runner   4096 .
drwxr-xr-x  3 runner runner   4096 ..
drwxrwxr-x  7 runner runner   4096 .git
-rw-rw-r--  1 runner runner    321 .gitattributes
drwxrwxr-x  4 runner runner   4096 .github
-rw-rw-r--  1 runner runner  16274 CHANGELOG-BBCODE.txt
-rw-rw-r--  1 runner runner  14895 CHANGELOG-SHORT.md
-rw-rw-r--  1 runner runner 231436 CHANGELOG.md
-rw-rw-r--  1 runner runner  46401 Containerfile
-rw-rw-r--  1 runner runner   2107 Justfile
-rw-rw-r--  1 runner runner  11357 LICENSE
drwxrwxr-x  2 runner runner   4096 build_files
drwxrwxr-x  2 runner runner   4096 docs
drwxrwxr-x  2 runner runner   4096 installer
drwxrwxr-x  2 runner runner   4096 just_scripts
drwxrwxr-x  4 runner runner   4096 system_files
```

### System Files Structure

```bash
$ find system_files -type d -maxdepth 2
system_files
system_files/deck
system_files/deck/silverblue
system_files/deck/shared
system_files/desktop
system_files/desktop/silverblue
system_files/desktop/kinoite
system_files/desktop/shared
system_files/nvidia
system_files/nvidia/shared
system_files/nvidia/silverblue
system_files/overrides
```

### Just Files Count

```bash
$ find system_files -name "*.just" | wc -l
21
```

### Container Manager Detection

```bash
$ just _container_mgr
docker
```

