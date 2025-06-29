# vim: set ft=make :

# Build Mesa from Git source using podman for testing cutting-edge graphics features
_mesa-git ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    OPTION={{ ACTION }}
    MESA_INSTALL_DIR="$HOME/mesa-git"
    MESA_RUN_SCRIPT="$MESA_INSTALL_DIR/run.sh"
    CTR_ID_FILE="$(realpath ./id.txt)"

    if [[ $UID -eq 0 ]]; then
        echo -e "\n${red}${bold}This script should not be run as root.${normal}\n"
        exit 1
    fi

    # Show status at the top with spacing and usage info
    echo ""
    echo -e "${bold}${blue}═══════════════════════════════════════════════════════════════${normal}"
    if [ -d "$MESA_INSTALL_DIR" ] && [ -x "$MESA_RUN_SCRIPT" ]; then
        echo -e "${green}${bold}Mesa Git installation found!${normal}"
        echo -e "${blue}Location:${normal}   $MESA_INSTALL_DIR"
        echo -e "${blue}Runner:${normal}     $MESA_RUN_SCRIPT"
        echo ""
        echo -e "${yellow}To use with Steam:${normal}"
        echo -e "  Set your game's launch options to:"
        echo -e "  ${bold}$MESA_RUN_SCRIPT %command%${normal}"
        echo ""
        echo -e "${yellow}To use with any program:${normal}"
        echo -e "  ${bold}$MESA_RUN_SCRIPT <your-program> [args...]${normal}"
        echo ""
    else
        echo -e "${red}${bold}Mesa Git installation not found${normal}"
        echo "Run 'ujust _mesa-git build' to build from source."
        echo ""
    fi
    echo -e "${bold}${blue}═══════════════════════════════════════════════════════════════${normal}"
    echo ""
    echo -e "${bold}Mesa Git Builder${normal}"
    echo -e "${blue}Choose an action:${normal}"
    echo -e "  ${bold}Build Mesa (from Git)${normal}     - Build Mesa from the latest git source."
    echo -e "  ${bold}Rebuild Mesa (force)${normal}      - Force a clean rebuild, even if already installed."
    echo -e "  ${bold}Cleanup Mesa build${normal}        - Remove Mesa Git installation and clean up containers."
    echo -e "  ${bold}Exit${normal}                      - Exit this menu."
    echo ""
    OPTION=$(ugum choose "Build Mesa (from Git)" "Rebuild Mesa (force)" "Cleanup Mesa build" "Exit")
    case "$OPTION" in
        "Build Mesa (from Git)") OPTION="build" ;;
        "Rebuild Mesa (force)") OPTION="rebuild" ;;
        "Cleanup Mesa build") OPTION="cleanup" ;;
        "Exit"|*) exit 0 ;;
    esac

    if [ "$OPTION" = "cleanup" ]; then
        echo -e "${yellow}Cleaning up Mesa Git installation...${normal}"
        if [ -d "$MESA_INSTALL_DIR" ]; then
            echo "Removing Mesa installation at $MESA_INSTALL_DIR..."
            rm -rf "$MESA_INSTALL_DIR"
        fi
        podman container prune -f 2>/dev/null || true
        echo -e "${green}Mesa Git cleanup completed${normal}"
        exit 0
    fi

    if [ "$OPTION" = "rebuild" ]; then
        echo -e "${yellow}Forcing rebuild of Mesa Git...${normal}"
        rm -rf "$MESA_INSTALL_DIR"
    elif [ "$OPTION" = "build" ]; then
        if [ -d "$MESA_INSTALL_DIR" ] && [ -x "$MESA_RUN_SCRIPT" ]; then
            echo -e "${yellow}${bold}Mesa Git installation already exists at $MESA_INSTALL_DIR${normal}"
            echo "Use the picker to rebuild or clean up."
            exit 0
        fi
    fi

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
    echo -e "\n${bold}${green}Mesa Git build completed!${normal}\n"
    echo -e "${blue}═══════════════════════════════════════════════════════════════${normal}"
    echo -e "${bold}${blue}Installation Location:${normal} ${bold}$MESA_INSTALL_DIR${normal}"
    echo -e "${bold}${blue}Runner Script:${normal}        ${bold}$MESA_RUN_SCRIPT${normal}"
    echo -e "${yellow}${bold}Usage Examples:${normal}"
    echo -e "  ${bold}# Test OpenGL:${normal}"
    echo -e "  ${green}$MESA_INSTALL_DIR/run.sh glxinfo | grep 'OpenGL version'${normal}"
    echo -e "  ${bold}# Test Vulkan:${normal}"
    echo -e "  ${green}$MESA_INSTALL_DIR/run.sh vulkaninfo | head -20${normal}"
    echo -e "  ${bold}# Run application with custom Mesa:${normal}"
    echo -e "  ${green}$MESA_INSTALL_DIR/run.sh your-application${normal}"
    echo -e "  ${bold}# Steam launch option:${normal}"
    echo -e "  ${green}$MESA_INSTALL_DIR/run.sh %command%${normal}"
    echo -e "${blue}═══════════════════════════════════════════════════════════════${normal}\n"
