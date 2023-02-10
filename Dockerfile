# syntax=docker/dockerfile:labs
ARG GO_VERSION="1.19"
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine AS obfs4proxy
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH

ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}
ADD https://github.com/Yawning/obfs4.git /app
WORKDIR /app
RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build go mod download
RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build CGO_ENABLED=0 go build -ldflags "-s -w" -trimpath -o /app/obfs4proxy ./obfs4proxy

FROM alpine:latest
LABEL maintainer="avpnusr"

ADD --link service /etc/service/

EXPOSE 8118 9050

RUN apk update --no-cache && apk upgrade -a --no-cache && apk --update --no-cache add privoxy runit tor torsocks tini curl \
&& addgroup -S tordocker \
&& adduser -S tordocker -G tordocker \
&& chown tordocker:tordocker /etc/service \
&& chown -R tordocker:tordocker /etc/service/*

COPY --link --from=obfs4proxy /app/obfs4proxy/obfs4proxy /usr/bin/obfs4proxy 

COPY <<EOT /docker-entrypoint.sh
#!/bin/sh
cp -f /etc/service/tor/torrc.base /etc/service/tor/torrc
if [ -n "\$BRIDGE" ]; then
  while read line; do echo "\${line//\\\$BRIDGE/\$BRIDGE}"; done < /etc/service/tor/torrc.bridge >> /etc/service/tor/torrc
fi
exec "\$@"
EOT

RUN chmod +x /docker-entrypoint.sh
HEALTHCHECK --interval=120s --timeout=15s --start-period=120s --retries=2 \
            CMD curl --fail -x http://127.0.0.1:8118 -s 'https://duckduckgogg42xjoc72x3sjasowoarfbgcmvfimaftt6twagswzczad.onion' -k > /dev/null && echo "HealthCheck succeeded..." || exit 1

USER tordocker

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
CMD ["runsvdir", "/etc/service"]
