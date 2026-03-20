ARG FEDORA_VERSION=43
FROM registry.fedoraproject.org/fedora:${FEDORA_VERSION}

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

RUN dnf -y upgrade --refresh \
    && dnf -y install \
        bash-completion \
        ca-certificates \
        curl \
        findutils \
        git \
        git-lfs \
        gh \
        jq \
        just \
        moby-engine \
        procps-ng \
        python3 \
        rsync \
        skopeo \
        sudo \
        tar \
        unzip \
        wget \
        which \
        xz \
        shadow-utils \
    && dnf clean all \
    && rm -rf /var/cache/dnf

RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

COPY devcontainer-post-start.sh /usr/local/bin/devcontainer-post-start.sh
RUN chmod 0755 /usr/local/bin/devcontainer-post-start.sh \
    && git lfs install --system

USER ${USERNAME}
WORKDIR /workspaces
