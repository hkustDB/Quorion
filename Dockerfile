FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl wget wget2 \
      unzip \
      pkg-config \
      libreadline-dev \
      zstd \
      tar \
      python3 python3-pip python3-venv python3-zstandard \
      git \
      build-essential \
      jq \
      openssl \
      less \
      vim \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1000 appuser
USER appuser
WORKDIR /home/appuser/Quorion

# COPY . .

CMD ["/bin/bash"]