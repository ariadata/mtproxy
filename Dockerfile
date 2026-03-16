FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    make \
    gcc \
    libc6-dev \
    libssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /mtproxy/sources
RUN git clone --single-branch --depth 1 https://github.com/TelegramMessenger/MTProxy.git . \
    && make -j$(nproc)

FROM debian:bookworm-slim

LABEL maintainer="Mehrdad Amini <pcmehrdad@gmail.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /mtproxy

COPY --from=builder /mtproxy/sources/objs/bin/mtproto-proxy .
COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh && \
    mkdir -p /data && \
    echo '#!/bin/sh' > /usr/local/bin/getstats && \
    echo 'curl -s http://127.0.0.1:2398/stats' >> /usr/local/bin/getstats && \
    chmod +x /usr/local/bin/getstats && \
    echo '#!/bin/sh' > /usr/local/bin/get_links && \
    echo 'cat /data/links.txt' >> /usr/local/bin/get_links && \
    chmod +x /usr/local/bin/get_links

VOLUME /data
EXPOSE 2398

ENTRYPOINT ["/docker-entrypoint.sh"]
