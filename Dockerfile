ARG RUSTUP_TOOLCHAIN=stable
FROM --platform=${BUILDPLATFORM:-linux/amd64} ghcr.io/topos-protocol/rust_builder:bullseye-${RUSTUP_TOOLCHAIN} AS base

ARG FEATURES
# Rust cache
ARG SCCACHE_S3_KEY_PREFIX
ARG SCCACHE_BUCKET
ARG SCCACHE_REGION
ARG RUSTC_WRAPPER
ARG PROTOC_VERSION=22.2

FROM --platform=${BUILDPLATFORM:-linux/amd64} base AS build
WORKDIR /usr/src/app
RUN git clone https://github.com/topos-protocol/topos.git .
RUN --mount=type=secret,id=aws,target=/root/.aws/credentials \
    --mount=type=cache,id=sccache,target=/root/.cache/sccache \
    cargo build --release --no-default-features --features=${FEATURES} \
    && sccache --show-stats


# Define the final image
FROM ubuntu:22.04 AS topos

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
    linux-tools-$(uname -r) \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

# Copy the binary from the build stage
COPY --from=build /usr/src/app/target/release/topos .

# Set necessary environment variables
ENV TCE_PORT=9090
ENV USER=topos
ENV UID=10001

RUN mkdir /tmp/node_config
RUN mkdir /tmp/shared

# Define the entry point to use flamegraph with topos
ENTRYPOINT ["./topos"]
