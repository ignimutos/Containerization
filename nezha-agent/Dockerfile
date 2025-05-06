FROM golang:alpine AS builder
ARG VERSION=1.10.0

RUN apk add --no-cache git && git clone https://github.com/nezhahq/agent /agent
WORKDIR /agent
RUN git checkout v${VERSION} && go generate ./...

WORKDIR /agent/cmd/agent
RUN env CGO_ENABLED=0 \
  go build -v -trimpath -ldflags \
  "-s -w -X github.com/nezhahq/agent/pkg/monitor.Version=${VERSION}"


FROM alpine:latest

ENV TZ=Asia/Shanghai \
  NEZHA_TLS=false \
  NEZHA_DEBUG=true \
  NEZHA_DISABLE_AUTO_UPDATE=true \
  NEZHA_DISABLE_COMMAND_EXECUTE=true \
  NEZHA_DISABLE_FORCE_UPDATE=true

COPY --from=builder /agent/cmd/agent/agent /agent
COPY misc/entrypoint.sh /entrypoint.sh

RUN apk add --no-cache util-linux tzdata
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]