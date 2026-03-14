ARG VERSION=2.10.0


FROM caddy:${VERSION}-builder-alpine AS builder-base

RUN xcaddy build \
  --with github.com/caddy-dns/cloudflare \
  --with github.com/caddyserver/transform-encoder \
  --with github.com/greenpau/caddy-security \
  --with github.com/greenpau/caddy-trace

FROM caddy:${VERSION}-builder-alpine AS builder-rr

RUN xcaddy build \
  --with github.com/caddy-dns/cloudflare \
  --with github.com/caddyserver/replace-response \
  --with github.com/caddyserver/transform-encoder \
  --with github.com/greenpau/caddy-security \
  --with github.com/greenpau/caddy-trace



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

FROM runtime-base AS caddy-rr
COPY --from=builder-rr /usr/bin/caddy /usr/bin/caddy
RUN chmod +x /usr/bin/caddy