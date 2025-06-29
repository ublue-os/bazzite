# vim: set ft=make :

# Build Mesa from Git source in a distrobox container for testing cutting-edge graphics features
build-mesa-git ACTION="build":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh

    # Configuration
    CONTAINER_NAME="fedora-mesa"
    CONTAINER_IMAGE="fedora:rawhide"
    MESA_INSTALL_DIR="$HOME/mesa-git-host"
    MESA_GIT_DIR="mesa-git"
    LOG_FILE="$HOME/mesa-build.log"

    # Colors for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    # Logging function
    log() {
        local level="$1"
        shift
        local message="$*"
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

        case "$level" in
            "INFO")
                echo -e "${GREEN}[INFO]${NC} $message" | tee -a "$LOG_FILE"
                ;;
            "WARN")
                echo -e "${YELLOW}[WARN]${NC} $message" | tee -a "$LOG_FILE"
                ;;
            "ERROR")
                echo -e "${RED}[ERROR]${NC} $message" | tee -a "$LOG_FILE"
                ;;
            "DEBUG")
                echo -e "${BLUE}[DEBUG]${NC} $message" | tee -a "$LOG_FILE"
                ;;
        esac
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    }

    # Error handling function
    handle_error() {
        local exit_code=$?
        local line_number=$1
        log "ERROR" "Script failed at line $line_number with exit code $exit_code"
        log "ERROR" "Check the log file at $LOG_FILE for details"

        # Cleanup on error
        if distrobox list | grep -q "$CONTAINER_NAME"; then
            log "WARN" "Stopping container $CONTAINER_NAME due to error"
            distrobox stop "$CONTAINER_NAME" 2>/dev/null || true
        fi

        exit $exit_code
    }

    # Set up error trap
    trap 'handle_error $LINENO' ERR

    # Function to check if command exists
    command_exists() {
        command -v "$1" >/dev/null 2>&1
    }

    # Function to check prerequisites
    check_prerequisites() {
        log "INFO" "Checking prerequisites..."

        local missing_tools=()

        if ! command_exists distrobox; then
            missing_tools+=("distrobox")
        fi

        if ! command_exists podman; then
            missing_tools+=("podman")
        fi

        if [ ${#missing_tools[@]} -ne 0 ]; then
            log "ERROR" "Missing required tools: ${missing_tools[*]}"
            log "ERROR" "Please install the missing tools and try again"
            exit 1
        fi

        log "INFO" "Prerequisites check passed"
    }

    # Function to check if container exists
    container_exists() {
        distrobox list | grep -q "^$CONTAINER_NAME" 2>/dev/null
    }

    # Function to check if container is running
    container_running() {
        podman ps --format "\{\{.Names\}\}" | grep -q "^$CONTAINER_NAME$" 2>/dev/null
    }

    # Function to create container
    create_container() {
        log "INFO" "Creating distrobox container '$CONTAINER_NAME'..."

        # Check if image needs to be pulled
        if ! podman images --format "\{\{.Repository\}\}:\{\{.Tag\}\}" | grep -q "^registry.fedoraproject.org/$CONTAINER_IMAGE$"; then
            log "INFO" "Pulling container image $CONTAINER_IMAGE..."
            if ! distrobox create --name "$CONTAINER_NAME" --image "$CONTAINER_IMAGE" --yes --additional-packages "sudo"; then
                log "ERROR" "Failed to create container"
                return 1
            fi
        else
            log "INFO" "Container image already available, creating container..."
            if ! distrobox create --name "$CONTAINER_NAME" --image "$CONTAINER_IMAGE" --yes --additional-packages "sudo"; then
                log "ERROR" "Failed to create container"
                return 1
            fi
        fi

        # Enter the container once to ensure it's fully initialized
        log "INFO" "Initializing container environment..."
        distrobox enter "$CONTAINER_NAME" -- bash -c "echo 'Container initialized'" || {
            log "WARN" "Initial container setup may have issues, continuing..."
        }

        log "INFO" "Container '$CONTAINER_NAME' created successfully"
    }

    # Function to start container if not running
    ensure_container_running() {
        if ! container_running; then
            log "INFO" "Starting container '$CONTAINER_NAME'..."
            if ! podman start "$CONTAINER_NAME" >/dev/null 2>&1; then
                log "ERROR" "Failed to start container"
                return 1
            fi
            # Wait a moment for container to fully start
            sleep 2
        fi
        log "INFO" "Container '$CONTAINER_NAME' is running"
    }

    # Function to execute command in container
    execute_in_container() {
        local command="$1"
        local description="$2"

        log "INFO" "$description"
        log "DEBUG" "Executing in container: $command"

        # Try distrobox enter first (most reliable for distrobox containers)
        if distrobox enter "$CONTAINER_NAME" -- bash -c "$command" 2>&1 | tee -a "$LOG_FILE"; then
            log "INFO" "Completed: $description"
            return 0
        fi

        local exit_code=$?
        log "ERROR" "Command execution failed: $description (exit code: $exit_code)"

        # Check the recent log output for specific errors
        if tail -20 "$LOG_FILE" | grep -q "sudo.*password\|permission denied\|not in sudoers"; then
            log "ERROR" "Permission/sudo error detected"
            log "ERROR" "This suggests the distrobox container doesn't have proper sudo access"
            log "ERROR" "Try recreating the container or check distrobox configuration"
        elif tail -20 "$LOG_FILE" | grep -q "ptsname\|ioctl\|runtime error\|OCI runtime error"; then
            log "ERROR" "Container runtime error detected"
            log "ERROR" "This appears to be a podman/container runtime issue"
        fi

        return 1
    }

    # Function to install dependencies
    install_dependencies() {
        log "INFO" "Installing build dependencies in container..."

        # Use sudo for all dnf commands - distrobox sets up passwordless sudo
        local install_cmd="
        set -e
        echo 'Starting dependency installation...'

        # Update package cache
        echo 'Updating package cache...'
        sudo dnf update -y

        # Install development tools
        echo 'Installing development tools...'
        sudo dnf group install 'Development Tools' -y || {
            echo 'Group install failed, installing individual packages...'
            sudo dnf install -y gcc gcc-c++ make automake autoconf libtool
        }

        # Install Mesa build dependencies
        echo 'Installing Mesa build dependencies...'
        sudo dnf builddep mesa -y || {
            echo 'builddep failed, installing individual packages...'
            sudo dnf install -y meson ninja-build cmake git wget bison flex \
                libdrm-devel libX11-devel libXext-devel libXfixes-devel \
                libXrandr-devel libXxf86vm-devel libxcb-devel libxshmfence-devel \
                libva-devel libvdpau-devel wayland-devel wayland-protocols-devel \
                vulkan-headers vulkan-loader-devel expat-devel zlib-devel \
                elfutils-libelf-devel libunwind-devel python3-mako \
                python3-ply llvm-devel clang-devel
        }

        # Install additional required packages
        echo 'Installing additional packages...'
        sudo dnf install -y meson ninja-build git wget python3-pyyaml

        echo 'Dependencies installed successfully'
        "

        execute_in_container "$install_cmd" "Installing build dependencies"
    }

    # Function to clone and build Mesa
    build_mesa() {
        log "INFO" "Cloning and building Mesa from git..."

        local build_cmd="
        set -e
        cd \$HOME

        # Clone Mesa if not exists, otherwise update
        if [ -d '$MESA_GIT_DIR' ]; then
            echo 'Updating existing Mesa repository...'
            cd '$MESA_GIT_DIR'
            git fetch origin
            git reset --hard origin/main
        else
            echo 'Cloning Mesa repository...'
            git clone https://gitlab.freedesktop.org/mesa/mesa.git '$MESA_GIT_DIR'
            cd '$MESA_GIT_DIR'
        fi

        # Clean previous build
        rm -rf build64

        # Configure build
        echo 'Configuring Mesa build...'
        meson setup build64 --libdir lib64 --prefix \$HOME/mesa-install \
            -Dgallium-drivers=radeonsi,softpipe,llvmpipe,zink \
            -Dvulkan-drivers=amd \
            -Dbuildtype=release

        # Build
        echo 'Building Mesa (this may take a while)...'
        ninja -C build64

        # Install
        echo 'Installing Mesa...'
        ninja -C build64 install

        echo 'Mesa build completed successfully'
        "

        execute_in_container "$build_cmd" "Building Mesa from git"
    }

    # Function to copy files from container
    copy_mesa_files() {
        log "INFO" "Copying Mesa installation from container to host..."

        # Remove existing installation if it exists
        if [ -d "$MESA_INSTALL_DIR" ]; then
            log "WARN" "Removing existing Mesa installation at $MESA_INSTALL_DIR"
            rm -rf "$MESA_INSTALL_DIR"
        fi

        # Get the container user's home directory dynamically
        local container_home
        container_home=$(distrobox enter "$CONTAINER_NAME" -- bash -c 'echo $HOME' 2>/dev/null)
        if [ -z "$container_home" ]; then
            log "ERROR" "Failed to get container home directory"
            return 1
        fi

        # Copy files using podman cp
        if ! podman cp "$CONTAINER_NAME:$container_home/mesa-install" "$MESA_INSTALL_DIR"; then
            log "ERROR" "Failed to copy Mesa installation from container"
            return 1
        fi

        log "INFO" "Mesa installation copied to $MESA_INSTALL_DIR"
    }

    # Function to create runner script
    create_runner_script() {
        log "INFO" "Creating Mesa runner script..."

        local runner_script="$MESA_INSTALL_DIR/mesa-run.sh"

        # Create the runner script using echo commands to avoid heredoc issues in Just
        echo '#!/bin/bash' > "$runner_script"
        echo '# Mesa Git Runner Script' >> "$runner_script"
        echo '# Use this script to run applications with the custom Mesa build' >> "$runner_script"
        echo '' >> "$runner_script"
        echo 'MESA_DIR="$(dirname "$(readlink -f "$0")")"' >> "$runner_script"
        echo '' >> "$runner_script"
        echo '# Set environment variables for Mesa' >> "$runner_script"
        echo 'export LD_LIBRARY_PATH="$MESA_DIR/lib64:$LD_LIBRARY_PATH"' >> "$runner_script"
        echo 'export LIBGL_DRIVERS_PATH="$MESA_DIR/lib64/dri"' >> "$runner_script"
        echo 'export VK_ICD_FILENAMES="$MESA_DIR/share/vulkan/icd.d/radeon_icd.x86_64.json"' >> "$runner_script"
        echo 'export LIBVA_DRIVERS_PATH="$MESA_DIR/lib64/dri"' >> "$runner_script"
        echo 'export VDPAU_DRIVER_PATH="$MESA_DIR/lib64/vdpau"' >> "$runner_script"
        echo '' >> "$runner_script"
        echo '# Additional Mesa debugging variables (uncomment as needed)' >> "$runner_script"
        echo '# export MESA_DEBUG=1' >> "$runner_script"
        echo '# export RADV_DEBUG=info' >> "$runner_script"
        echo '# export MESA_GLSL_CACHE_DISABLE=1' >> "$runner_script"
        echo '' >> "$runner_script"
        echo 'if [ $# -eq 0 ]; then' >> "$runner_script"
        echo '    echo "Mesa Git Runner Script"' >> "$runner_script"
        echo '    echo "Usage: $0 <command> [arguments...]"' >> "$runner_script"
        echo '    echo ""' >> "$runner_script"
        echo '    echo "Environment variables set:"' >> "$runner_script"
        echo '    echo "  LD_LIBRARY_PATH=$LD_LIBRARY_PATH"' >> "$runner_script"
        echo '    echo "  LIBGL_DRIVERS_PATH=$LIBGL_DRIVERS_PATH"' >> "$runner_script"
        echo '    echo "  VK_ICD_FILENAMES=$VK_ICD_FILENAMES"' >> "$runner_script"
        echo '    echo "  LIBVA_DRIVERS_PATH=$LIBVA_DRIVERS_PATH"' >> "$runner_script"
        echo '    echo "  VDPAU_DRIVER_PATH=$VDPAU_DRIVER_PATH"' >> "$runner_script"
        echo '    echo ""' >> "$runner_script"
        echo '    echo "Examples:"' >> "$runner_script"
        echo '    echo "  $0 glxinfo"' >> "$runner_script"
        echo '    echo "  $0 vulkaninfo"' >> "$runner_script"
        echo '    echo "  $0 your-application"' >> "$runner_script"
        echo '    exit 0' >> "$runner_script"
        echo 'fi' >> "$runner_script"
        echo '' >> "$runner_script"
        echo 'exec "$@"' >> "$runner_script"

        chmod +x "$runner_script"
        log "INFO" "Runner script created at $runner_script"
    }

    # Function to cleanup container
    cleanup_container() {
        if [ "${1:-}" = "--keep-container" ]; then
            log "INFO" "Keeping container as requested"
            return 0
        fi

        log "INFO" "Cleaning up container..."

        if container_running; then
            log "INFO" "Stopping container..."
            distrobox stop "$CONTAINER_NAME" || log "WARN" "Failed to stop container"
        fi

        if container_exists; then
            log "INFO" "Removing container..."
            distrobox rm "$CONTAINER_NAME" --force || log "WARN" "Failed to remove container"
        fi

        log "INFO" "Container cleanup completed"
    }

    # Function to verify clean environment and cleanup if needed
    verify_clean_environment() {
        log "INFO" "Verifying clean environment..."
        local cleanup_needed=false

        # Check for existing Mesa installation
        if [ -d "$MESA_INSTALL_DIR" ]; then
            log "WARN" "Found existing Mesa installation at $MESA_INSTALL_DIR"
            cleanup_needed=true
        fi

        # Check for existing log file
        if [ -f "$LOG_FILE" ]; then
            log "WARN" "Found existing log file at $LOG_FILE"
            cleanup_needed=true
        fi

        # Check for existing container
        if container_exists; then
            log "WARN" "Found existing container '$CONTAINER_NAME'"
            cleanup_needed=true
        fi

        # Perform cleanup if needed
        if [ "$cleanup_needed" = true ]; then
            log "INFO" "Cleaning up existing files and containers..."

            # Stop and remove container
            if container_running; then
                log "INFO" "Stopping existing container..."
                distrobox stop "$CONTAINER_NAME" 2>/dev/null || log "WARN" "Failed to stop container"
            fi

            if container_exists; then
                log "INFO" "Removing existing container..."
                distrobox rm "$CONTAINER_NAME" --force 2>/dev/null || log "WARN" "Failed to remove container"
            fi

            # Remove Mesa installation
            if [ -d "$MESA_INSTALL_DIR" ]; then
                log "INFO" "Removing existing Mesa installation..."
                rm -rf "$MESA_INSTALL_DIR"
            fi

            # Clean up podman containers
            log "INFO" "Cleaning up any leftover podman containers..."
            podman container prune -f 2>/dev/null || true

            log "INFO" "Cleanup completed"
        fi

        log "INFO" "Environment verification passed - ready for fresh build"
    }

    # Function to show build info
    show_build_info() {
        log "INFO" "Mesa Git Builder completed successfully!"
        echo ""
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}                    BUILD COMPLETED SUCCESSFULLY                  ${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${BLUE}Installation Location:${NC} $MESA_INSTALL_DIR"
        echo -e "${BLUE}Runner Script:${NC}        $MESA_INSTALL_DIR/mesa-run.sh"
        echo -e "${BLUE}Log File:${NC}             $LOG_FILE"
        echo ""
        echo -e "${YELLOW}Usage Examples:${NC}"
        echo "  # Test OpenGL:"
        echo "  $MESA_INSTALL_DIR/mesa-run.sh glxinfo | grep 'OpenGL version'"
        echo ""
        echo "  # Test Vulkan:"
        echo "  $MESA_INSTALL_DIR/mesa-run.sh vulkaninfo | head -20"
        echo ""
        echo "  # Run application with custom Mesa:"
        echo "  $MESA_INSTALL_DIR/mesa-run.sh your-application"
        echo ""
    }

    # Main logic
    OPTION="{{ ACTION }}"
    if [ "$OPTION" == "build" ]; then
        if [ -d "$MESA_INSTALL_DIR" ] && [ -x "$MESA_INSTALL_DIR/mesa-run.sh" ]; then
            echo "${yellow}${bold}Mesa Git installation already exists at $MESA_INSTALL_DIR${normal}"
            CHOICE=$(ugum choose "Rebuild Mesa" "Keep existing installation" "Clean up and exit")
            case $CHOICE in
                "Rebuild Mesa")
                    OPTION="rebuild"
                    ;;
                "Keep existing installation")
                    echo "Using existing Mesa installation"
                    exit 0
                    ;;
                "Clean up and exit")
                    OPTION="cleanup"
                    ;;
            esac
        fi
    fi

    case $OPTION in
        "build"|"rebuild")
            echo "Building Mesa from Git source..."
            # Initialize log
            echo "Mesa Git Builder Log - $(date)" > "$LOG_FILE"
            log "INFO" "Starting Mesa Git Builder for Bazzite"
            log "INFO" "Log file: $LOG_FILE"

            # Verify clean environment and cleanup if needed
            verify_clean_environment

            # Check prerequisites
            check_prerequisites

            # Create or ensure container exists
            if ! container_exists; then
                create_container
            else
                log "INFO" "Container '$CONTAINER_NAME' already exists"
            fi

            # Ensure container is running
            ensure_container_running

            # Install dependencies and build Mesa
            install_dependencies
            build_mesa
            copy_mesa_files
            create_runner_script

            # Cleanup container
            cleanup_container

            # Show completion info
            show_build_info
            ;;
        "cleanup")
            echo "Cleaning up Mesa Git installation and container..."
            cleanup_container
            if [ -d "$MESA_INSTALL_DIR" ]; then
                echo "Removing Mesa installation directory..."
                rm -rf "$MESA_INSTALL_DIR"
            fi
            echo "Cleanup completed"
            ;;
        "status")
            echo "Checking Mesa Git installation status..."
            if [ -d "$MESA_INSTALL_DIR" ] && [ -x "$MESA_INSTALL_DIR/mesa-run.sh" ]; then
                echo "${green}${bold}Mesa Git installation found at: $MESA_INSTALL_DIR${normal}"
                echo "Runner script: $MESA_INSTALL_DIR/mesa-run.sh"
                if [ -f "$LOG_FILE" ]; then
                    echo "Last build log: $LOG_FILE"
                fi
                if container_exists; then
                    echo "Build container: $CONTAINER_NAME (exists)"
                else
                    echo "Build container: $CONTAINER_NAME (not found)"
                fi
            else
                echo "${red}${bold}Mesa Git installation not found${normal}"
                echo "Run 'ujust build-mesa-git' to build from source"
            fi
            ;;
        *)
            echo "Usage:"
            echo "  ujust build-mesa-git build    - Build Mesa from Git source"
            echo "  ujust build-mesa-git rebuild  - Force rebuild even if installation exists"
            echo "  ujust build-mesa-git cleanup  - Remove installation and cleanup"
            echo "  ujust build-mesa-git status   - Check installation status"
            ;;
    esac

# Test the custom Mesa build with OpenGL info
test-mesa-git:
    #!/usr/bin/bash
    MESA_INSTALL_DIR="$HOME/mesa-git-host"

    if [ ! -d "$MESA_INSTALL_DIR" ] || [ ! -x "$MESA_INSTALL_DIR/mesa-run.sh" ]; then
        echo "Mesa Git installation not found. Run 'ujust build-mesa-git' first."
        exit 1
    fi

    echo "Testing Mesa Git build..."
    echo ""
    echo "OpenGL Information:"
    echo "==================="
    "$MESA_INSTALL_DIR/mesa-run.sh" glxinfo | grep -E "OpenGL (vendor|renderer|version|shading)"
    echo ""
    echo "Vulkan Information:"
    echo "==================="
    "$MESA_INSTALL_DIR/mesa-run.sh" vulkaninfo | head -20
    echo ""
    echo "Mesa runner script location: $MESA_INSTALL_DIR/mesa-run.sh"
    echo ""
    echo "Usage examples:"
    echo "  $MESA_INSTALL_DIR/mesa-run.sh your-application"
    echo "  $MESA_INSTALL_DIR/mesa-run.sh steam"
    echo "  $MESA_INSTALL_DIR/mesa-run.sh mangohud your-game"

# Remove Mesa Git installation and cleanup
cleanup-mesa-git:
    #!/usr/bin/bash
    CONTAINER_NAME="fedora-mesa"
    MESA_INSTALL_DIR="$HOME/mesa-git-host"
    LOG_FILE="$HOME/mesa-build.log"

    echo "Cleaning up Mesa Git installation..."

    # Stop and remove container if it exists
    if distrobox list | grep -q "^$CONTAINER_NAME"; then
        echo "Stopping and removing container '$CONTAINER_NAME'..."
        distrobox stop "$CONTAINER_NAME" 2>/dev/null || true
        distrobox rm "$CONTAINER_NAME" --force 2>/dev/null || true
    fi

    # Remove Mesa installation directory
    if [ -d "$MESA_INSTALL_DIR" ]; then
        echo "Removing Mesa installation at $MESA_INSTALL_DIR..."
        rm -rf "$MESA_INSTALL_DIR"
    fi

    # Remove log file
    if [ -f "$LOG_FILE" ]; then
        echo "Removing log file at $LOG_FILE..."
        rm -f "$LOG_FILE"
    fi

    # Clean up any leftover containers
    podman container prune -f 2>/dev/null || true

    echo "Mesa Git cleanup completed"
