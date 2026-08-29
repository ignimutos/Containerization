# syntax=docker/dockerfile:1.7
ARG VERSION=2.11.2


FROM caddy:${VERSION}-builder-alpine AS builder-base

RUN --mount=type=cache,target=/go/pkg/mod,id=containerization-caddy-go-mod \
    --mount=type=cache,target=/root/.cache/go-build,id=containerization-caddy-go-build \
    xcaddy build \
      --with github.com/caddy-dns/cloudflare \
      --with github.com/caddyserver/transform-encoder \
      --with github.com/greenpau/caddy-security \
      --with github.com/greenpau/caddy-trace \
      --with github.com/mholt/caddy-l4 \
      --with github.com/caddyserver/replace-response

FROM caddy:${VERSION}-builder-alpine AS builder-naive

RUN --mount=type=cache,target=/go/pkg/mod,id=containerization-caddy-go-mod \
    --mount=type=cache,target=/root/.cache/go-build,id=containerization-caddy-go-build \
    xcaddy build \
      --with github.com/caddy-dns/cloudflare \
      --with github.com/caddyserver/transform-encoder \
      --with github.com/greenpau/caddy-security \
      --with github.com/greenpau/caddy-trace \
      --with github.com/mholt/caddy-l4 \
      --with github.com/caddyserver/replace-response \
      --with github.com/caddyserver/forwardproxy=github.com/klzgrad/forwardproxy@naive



FROM caddy:${VERSION}-alpine AS runtime-base

ENV TZ=Asia/Shanghai

RUN apk add --no-cache tzdata

COPY ./misc/* /usr/bin
RUN chmod +x /usr/bin/caddy-*

VOLUME [ "/data/caddy" ]

EXPOSE 80 443

ENTRYPOINT [ "caddy" ]
CMD [ "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile" ]



FROM runtime-base AS caddy-base
COPY --from=builder-base /usr/bin/caddy /usr/bin/caddy
RUN chmod +x /usr/bin/caddy

FROM runtime-base AS caddy-naive
COPY --from=builder-naive /usr/bin/caddy /usr/bin/caddy
RUN chmod +x /usr/bin/caddy