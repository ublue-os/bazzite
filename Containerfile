# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

# Base image: Bazzite DX (KDE Plasma + developer tooling). KDE stays as a
# fallback session; Mango is added alongside it.
FROM ghcr.io/ublue-os/bazzite-dx:stable

### MODIFICATIONS
## Packages, COPRs, themes and dotfiles are all handled in build_files/build.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
