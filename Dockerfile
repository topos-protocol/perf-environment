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

# Define base image for downloading and extracting the binary
FROM ubuntu:20.04 AS downloader

# Set the GitHub repository
ARG GITHUB_REPO="topos-protocol/topos"
# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary tools: curl for downloading, jq for JSON processing
RUN apt-get update && apt-get install -y \
    cmake \
    git \
    curl \
    jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.cargo/bin:${PATH}"

# Fetch the latest release URL using GitHub's API and download the binary tarball
RUN curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" \
    | jq -r '.assets[0].browser_download_url' \
    | xargs curl -Lo app.tar.gz

# Extract the binary to /usr/local/bin and clean up the tarball
RUN tar -xzf app.tar.gz -C /usr/local/bin && rm app.tar.gz \
    && chmod +x /usr/local/bin/topos-v0.1.0-rc.5-aarch64

# Define the final image
FROM ubuntu:20.04 AS final

ENV TCE_PORT=9090
ENV USER=topos
ENV UID=10001
ENV PATH="${PATH}:/usr/src/app"

WORKDIR /usr/src/app

# Install Rust using rustup (the official Rust toolchain installer)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install cargo-flamegraph
RUN cargo install flamegraph

# Copy the binary from the downloader stage
COPY --from=downloader /usr/local/bin/topos-v0.1.0-rc.5-aarch64 ./topos
COPY --from=downloader /usr/src/app/.cargo/bin/cargo-flamegraph ./flamegraph

# Install runtime dependencies such as ca-certificates
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /tmp/node_config
RUN mkdir /tmp/shared

# Define the entry point to use the script
ENTRYPOINT ["flamegraph", "topos"]
