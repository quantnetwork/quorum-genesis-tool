# Use an official Node image (no NodeSource curl|bash)
FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Optional: match your previous machine-id + kube dir
RUN set -eux; \
    mkdir -p /root/.kube; \
    echo "fd97de6b91a121428112c52e5fe04a15" > /etc/machine-id

# System deps you had (trimmed obsolete ones)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      pkg-config ca-certificates gnupg lsb-release jq libc6-dev make curl wget \
      vim dnsutils unzip libsodium-dev; \
    rm -rf /var/lib/apt/lists/*

# kubectl (same approach you used)
RUN set -eux; \
    KUBECTL_VERSION="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"; \
    curl -s "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
      -o /usr/local/bin/kubectl; \
    chmod a+x /usr/local/bin/kubectl

# --- Install your package from GitHub Packages securely ---
# These are set by your GitHub Actions build step:
#   build-arg SCOPE=@quantnetwork
#   build-arg PACKAGE=@quantnetwork/quorum-genesis-tool
#   build-arg VERSION=<published version>
ARG SCOPE=@quantnetwork
ARG PACKAGE=@quantnetwork/quorum-genesis-tool
ARG VERSION

# Pass the GitHub token as a BuildKit secret named "npm_token"
# (workflow does: secrets: "npm_token=${{ secrets.GITHUB_TOKEN }}")
RUN --mount=type=secret,id=npm_token \
    set -eux; \
    TOKEN="$(cat /run/secrets/npm_token)"; \
    printf "%s:registry=https://npm.pkg.github.com\n//npm.pkg.github.com/:_authToken=%s\nalways-auth=true\n" "$SCOPE" "$TOKEN" > /tmp/.npmrc; \
    NPM_CONFIG_USERCONFIG=/tmp/.npmrc npm i -g "${PACKAGE}@${VERSION}"; \
    rm -f /tmp/.npmrc

# AWS CLI v2 (your original steps)
RUN set -eux; \
    curl -fsSLo awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"; \
    unzip awscliv2.zip; \
    ./aws/install; \
    rm -rf /var/lib/apt/lists/* aws awscliv2.zip

# Optional: basic smoke check (don’t fail build if it just prints help)
RUN quorum-genesis-tool --help || true

# If this image is meant to run the CLI directly:
ENTRYPOINT ["quorum-genesis-tool"]
