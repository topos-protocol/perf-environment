# Setup runtime environment
FROM ubuntu:22.04

# Install necessary packages including perf
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    cmake \
    clang \
    lld \
    libssl-dev \
    pkg-config \
    libc6-dev \
    protobuf-compiler \
    build-essential \
    linux-tools-common \
    linux-tools-generic \
    linux-tools-$(uname -r) \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc

# Ensure Cargo is in PATH for subsequent commands
ENV PATH="/root/.cargo/bin:${PATH}"

# Clone the repository and checkout the specific PR branch
RUN git clone https://github.com/topos-protocol/topos.git . \
    && git fetch origin pull/493/head:PR-branch \
    && git checkout PR-branch

ENV RUSTFLAGS="-C force-frame-pointers=yes symbol-mangling-version=v0"

# Build the application including debug symbols
RUN cargo build --release

ENV TCE_PORT=9090
ENV USER=topos
ENV UID=10001

# Set up directories used by the application and for perf data
RUN mkdir /tmp/node_config /tmp/shared 

# Define a script as the entry point to run perf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

