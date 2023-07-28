ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

######################
##     BAZZITE      ##
######################

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS bazzite

ARG IMAGE_NAME="${IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

COPY system_files/desktop /

COPY --from=ghcr.io/ublue-os/akmods:${FEDORA_MAJOR_VERSION} /rpms /tmp/akmods-rpms
COPY --from=ghcr.io/ublue-os/ublue-update:latest /rpms/ublue-update.noarch.rpm /tmp/rpms/ublue-update.noarch.rpm
COPY --from=ghcr.io/ublue-os/bling:latest /rpms/ublue-os-wallpapers-*.noarch.rpm /tmp/rpms/ublue-os-wallpapers.rpm

COPY build.sh /tmp/build.sh
RUN /tmp/build.sh && \
    rm -rf \
        /tmp/* \
        /var/* && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp && \
    mkdir -p /var/lib/duperemove && \
    ostree container commit

######################
##   BAZZITE-DECK   ##
######################

FROM bazzite as bazzite-deck

ARG IMAGE_NAME="${IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

COPY system_files/deck /
COPY --from=ghcr.io/ublue-os/akmods:${FEDORA_MAJOR_VERSION} /rpms /tmp/akmods-rpms

COPY build-deck.sh /tmp/build-deck.sh
RUN /tmp/build-deck.sh && \
    rm -f /usr/etc/sddm.conf && \
    rm -rf \
        /tmp/* \
        /var/* && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp && \
    mkdir -p /var/lib/duperemove && \
    mkdir -p /var/lib/bluetooth && \
    ostree container commit
