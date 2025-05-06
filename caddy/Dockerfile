ARG VERSION=2.10.0


FROM caddy:${VERSION}-builder-alpine AS builder

RUN xcaddy build \
  --with github.com/caddy-dns/cloudflare \
  --with github.com/caddyserver/transform-encoder \
  --with github.com/greenpau/caddy-security \
  --with github.com/greenpau/caddy-trace


FROM caddy:${VERSION}-alpine

ENV TZ=Asia/Shanghai

RUN apk add --no-cache tzdata

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY ./misc/* /usr/bin

RUN chmod +x /usr/bin/caddy /usr/bin/caddy-reload /usr/bin/caddy-fmt

VOLUME [ "/data/caddy" ]

EXPOSE 80 443

ENTRYPOINT [ "caddy" ]
CMD [ "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile" ]
