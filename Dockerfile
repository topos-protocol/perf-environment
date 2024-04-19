ARG RUSTUP_TOOLCHAIN=stable
FROM --platform=${BUILDPLATFORM:-linux/amd64} ghcr.io/topos-protocol/rust_builder:bullseye-${RUSTUP_TOOLCHAIN} AS base

ARG FEATURES
# Rust cache
ARG SCCACHE_S3_KEY_PREFIX
ARG SCCACHE_BUCKET
ARG SCCACHE_REGION
ARG RUSTC_WRAPPER
ARG PROTOC_VERSION=22.2

WORKDIR /usr/src/app

FROM --platform=${BUILDPLATFORM:-linux/amd64} base AS build
COPY . .
RUN --mount=type=secret,id=aws,target=/root/.aws/credentials \
    --mount=type=cache,id=sccache,target=/root/.cache/sccache \
    cargo build --release --no-default-features --features=${FEATURES} \
    && sccache --show-stats

# Fetch and install the binary in the downloader stage
FROM ubuntu:20.04 AS downloader

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the GitHub repository
ARG GITHUB_REPO="topos-protocol/topos"

# Fetch the latest release URL using GitHub's API and download the binary tarball
RUN curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" \
    | jq -r '.assets[0].browser_download_url' \
    | xargs curl -Lo app.tar.gz

# Extract the binary to /usr/local/bin and clean up the tarball
RUN tar -xzf app.tar.gz -C /usr/local/bin && rm app.tar.gz \
    && chmod +x /usr/local/bin/topos-v0.1.0-rc.5-aarch64

# Define the final image
FROM ubuntu:20.04 AS final

ENV DEBIAN_FRONTEND=noninteractive
# Install runtime dependencies such as ca-certificates
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    cmake \
    build-essential \
    linux-tools-common \
    linux-tools-generic \
    linux-tools-6.5.0-27-generic \
    linux-cloud-tools-6.5.0-27-generic \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

# Copy the binary from the downloader stage
COPY --from=downloader /usr/local/bin/topos-v0.1.0-rc.5-aarch64 ./topos

# Set necessary environment variables
ENV TCE_PORT=9090
ENV USER=topos
ENV UID=10001

# Setup cargo and Rust environment
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo install flamegraph

# Define the entry point to use flamegraph with topos
ENTRYPOINT ["timeout", "300s", "flamegraph", "--", "topos"]
