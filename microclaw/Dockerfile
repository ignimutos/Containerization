FROM node:25-trixie-slim AS base

ENV HOME=/root/microclaw

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    python3 \
    python3-pip \
    ca-certificates \
    libssl3 \
    libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN curl -fsSL https://microclaw.ai/install.sh | bash \
    && mkdir -p /root/microclaw/.microclaw /app/tmp

ENTRYPOINT ["microclaw"]



FROM base AS builtin

ARG VENV_DIR=/root/.venv/builtin
ENV PATH="$VENV_DIR/bin:$PATH"

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://pinchtab.com/install.sh | bash \
    && npm cache clean --force

RUN python3 -m venv "$VENV_DIR" \
    && "$VENV_DIR/bin/pip" install --no-cache-dir --upgrade pip \
    && "$VENV_DIR/bin/pip" install --no-cache-dir "scrapling[ai]"
