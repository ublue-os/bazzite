# vim: set ft=make :

# Build Mesa from Git source using podman for testing cutting-edge graphics features
build-mesa-git ACTION="build":
    #!/usr/bin/bash
    if [[ $UID -eq 0 ]]; then
        echo "This script should not be run as root."
        exit 1
    fi

    MESA_INSTALL_DIR="$HOME/mesa-git-host"
    MESA_RUN_SCRIPT="$MESA_INSTALL_DIR/mesa-run.sh"
    CTR_ID_FILE="$(realpath ./id.txt)"

    rm -rf "$MESA_INSTALL_DIR"

    cat <<'CONTAINERFILEEOF' | podman --transient-store build \
        --build-arg MESA_INSTALL_DIR="$MESA_INSTALL_DIR" \
        --build-arg MESA_RUN_SCRIPT="$MESA_RUN_SCRIPT" \
        --iidfile "$CTR_ID_FILE" -f -
    ARG MESA_INSTALL_DIR=${MESA_INSTALL_DIR}
    ARG MESA_RUN_SCRIPT=${MESA_RUN_SCRIPT}

    FROM fedora:rawhide as builder
    ARG MESA_INSTALL_DIR
    ARG MESA_RUN_SCRIPT

    RUN dnf -y update && \
        dnf -y install gcc gcc-c++ make automake autoconf libtool \
            meson ninja-build git wget python3-pyyaml \
            bison flex glslang cmake libglvnd-core-devel \
            libdrm-devel libX11-devel libXext-devel libXfixes-devel \
            libXrandr-devel libXxf86vm-devel libxcb-devel libxshmfence-devel \
            libva-devel libvdpau-devel wayland-devel wayland-protocols-devel \
            vulkan-headers vulkan-loader-devel expat-devel zlib-devel \
            elfutils-libelf-devel libunwind-devel python3-mako python3-ply llvm-devel clang-devel

    WORKDIR /work
    RUN git clone https://gitlab.freedesktop.org/mesa/mesa.git mesa
    WORKDIR /work/mesa
    RUN meson setup build64 --libdir lib64 --prefix "${MESA_INSTALL_DIR}" \
        -Dgallium-drivers=radeonsi,softpipe,llvmpipe,zink \
        -Dvulkan-drivers=amd \
        -Dbuildtype=release || { echo "Meson setup failed. This may be a Mesa git issue."; exit 2; }
    RUN ninja -C build64 install || { echo "Mesa build failed. This may be a Mesa git issue."; exit 2; }
    RUN mkdir -p "${MESA_INSTALL_DIR}" && \
        echo '#!/bin/bash' > "${MESA_RUN_SCRIPT}" && \
        echo '# Mesa Git Runner Script' >> "${MESA_RUN_SCRIPT}" && \
        echo 'MESA_DIR="$(dirname \"$(readlink -f \"$0\")\")"' >> "${MESA_RUN_SCRIPT}" && \
        echo 'export LD_LIBRARY_PATH="$MESA_DIR/lib64:$LD_LIBRARY_PATH"' >> "${MESA_RUN_SCRIPT}" && \
        echo 'export LIBGL_DRIVERS_PATH="$MESA_DIR/lib64/dri"' >> "${MESA_RUN_SCRIPT}" && \
        echo 'export VK_ICD_FILENAMES="$MESA_DIR/share/vulkan/icd.d/radeon_icd.x86_64.json"' >> "${MESA_RUN_SCRIPT}" && \
        echo 'export LIBVA_DRIVERS_PATH="$MESA_DIR/lib64/dri"' >> "${MESA_RUN_SCRIPT}" && \
        echo 'export VDPAU_DRIVER_PATH="$MESA_DIR/lib64/vdpau"' >> "${MESA_RUN_SCRIPT}" && \
        echo '' >> "${MESA_RUN_SCRIPT}" && \
        echo '# Additional Mesa debugging variables (uncomment as needed)' >> "${MESA_RUN_SCRIPT}" && \
        echo '# export MESA_DEBUG=1' >> "${MESA_RUN_SCRIPT}" && \
        echo '# export RADV_DEBUG=info' >> "${MESA_RUN_SCRIPT}" && \
        echo '# export MESA_GLSL_CACHE_DISABLE=1' >> "${MESA_RUN_SCRIPT}" && \
        echo '' >> "${MESA_RUN_SCRIPT}" && \
        echo 'if [ $# -eq 0 ]; then' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo "Mesa Git Runner Script"' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo "Usage: $0 <command> [arguments...]"' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo ""' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo "Environment variables set:"' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo "  LD_LIBRARY_PATH=$LD_LIBRARY_PATH"' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo "  LIBGL_DRIVERS_PATH=$LIBGL_DRIVERS_PATH"' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo "  VK_ICD_FILENAMES=$VK_ICD_FILENAMES"' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo "  LIBVA_DRIVERS_PATH=$LIBVA_DRIVERS_PATH"' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo "  VDPAU_DRIVER_PATH=$VDPAU_DRIVER_PATH"' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo ""' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo "Examples:"' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo "  $0 glxinfo"' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo "  $0 vulkaninfo"' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo "  $0 your-application"' >> "${MESA_RUN_SCRIPT}" && \
        echo '    echo "  $0 %command%    # Steam launch option"' >> "${MESA_RUN_SCRIPT}" && \
        echo '    exit 0' >> "${MESA_RUN_SCRIPT}" && \
        echo 'fi' >> "${MESA_RUN_SCRIPT}" && \
        echo '' >> "${MESA_RUN_SCRIPT}" && \
        echo 'exec "$@"' >> "${MESA_RUN_SCRIPT}" && \
        chmod +x "${MESA_RUN_SCRIPT}"

    FROM scratch
    ARG MESA_INSTALL_DIR
    COPY --from=builder ${MESA_INSTALL_DIR} ${MESA_INSTALL_DIR}
    CONTAINERFILEEOF

    podman create --name mesa-git-tmp $(cat "$CTR_ID_FILE")
    podman cp mesa-git-tmp:$MESA_INSTALL_DIR $MESA_INSTALL_DIR
    podman rm mesa-git-tmp
    podman rmi $(cat "$CTR_ID_FILE")
    rm "$CTR_ID_FILE"
    echo "Mesa Git build completed!"
    echo "Installation Location: $MESA_INSTALL_DIR"
    echo "Runner Script:        $MESA_INSTALL_DIR/mesa-run.sh"
    echo "Usage Examples:"
    echo "  # Test OpenGL:"
    echo "  $MESA_INSTALL_DIR/mesa-run.sh glxinfo | grep 'OpenGL version'"
    echo "  # Test Vulkan:"
    echo "  $MESA_INSTALL_DIR/mesa-run.sh vulkaninfo | head -20"
    echo "  # Run application with custom Mesa:"
    echo "  $MESA_INSTALL_DIR/mesa-run.sh your-application"
    echo "  # Steam launch option:"
    echo "  $MESA_INSTALL_DIR/mesa-run.sh %command%"

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
    echo "  $MESA_INSTALL_DIR/mesa-run.sh %command%    # Steam launch option"

# Remove Mesa Git installation and cleanup
cleanup-mesa-git:
    #!/usr/bin/bash
    MESA_INSTALL_DIR="$HOME/mesa-git-host"
    echo "Cleaning up Mesa Git installation..."
    if [ -d "$MESA_INSTALL_DIR" ]; then
        echo "Removing Mesa installation at $MESA_INSTALL_DIR..."
        rm -rf "$MESA_INSTALL_DIR"
    fi
    podman container prune -f 2>/dev/null || true
    echo "Mesa Git cleanup completed"
