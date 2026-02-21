FROM pikuzheng/smartdns:ui

COPY misc/smartdns.crt /usr/local/share/ca-certificates/smartdns.crt

RUN sed -i 's/https/http/g' /etc/apk/repositories &&\
  apk update &&\
  apk add --no-cache ca-certificates &&\
  update-ca-certificates
