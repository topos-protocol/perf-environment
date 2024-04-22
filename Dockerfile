ARG RUSTUP_TOOLCHAIN=stable
FROM --platform=${BUILDPLATFORM:-linux/amd64} ghcr.io/topos-protocol/rust_builder:bullseye-${RUSTUP_TOOLCHAIN} AS base

ARG FEATURES

FROM --platform=${BUILDPLATFORM:-linux/amd64} base AS build
WORKDIR /usr/src/app
RUN git clone https://github.com/topos-protocol/topos.git .
RUN cargo build --no-default-features --features=${FEATURES}


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
COPY --from=build /usr/src/app/target/debug/topos .

# Set necessary environment variables
ENV TCE_PORT=9090
ENV USER=topos
ENV UID=10001

RUN mkdir /tmp/node_config
RUN mkdir /tmp/shared

# Define the entry point to use flamegraph with topos
ENTRYPOINT ["./topos"]
