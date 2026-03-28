git clone https://github.com/NripeshN/bazzite.git
cd bazzite
git checkout apple-silicon

sudo podman build \
  --platform linux/arm64 \
  -f Containerfile.arm \
  --build-arg BASE_IMAGE_NAME=kinoite \
  --build-arg FEDORA_VERSION=42 \
  --build-arg IMAGE_NAME=bazzite-arm \
  --build-arg IMAGE_VENDOR=nripeshn \
  --build-arg IMAGE_BRANCH=apple-silicon \
  --build-arg VERSION_TAG=local \
  --build-arg VERSION_PRETTY="Local Build" \
  --build-arg SHA_HEAD_SHORT=local \
  -t ghcr.io/nripeshn/bazzite-arm:latest \
  .

rpm-ostree rebase ostree-image-signed:docker://localhost/ghcr.io/nripeshn/bazzite-arm:latest
systemctl reboot