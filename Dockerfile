FROM alpine:3.12
LABEL maintainer="avpnusr"

COPY service /etc/service/

EXPOSE 8118 9050

RUN apk update --no-cache && apk upgrade -a --no-cache && apk --update --no-cache add privoxy tor runit tini wget \
&& addgroup -S tordocker \
&& adduser -S tordocker -G tordocker \
&& chown tordocker:tordocker /etc/service \
&& chown -R tordocker:tordocker /etc/service/*

HEALTHCHECK --interval=120s --timeout=15s --start-period=120s --retries=2 \
            CMD wget --no-check-certificate -e use_proxy=yes -e https_proxy=127.0.0.1:8118 --quiet --spider 'https://duckduckgogg42xjoc72x3sjasowoarfbgcmvfimaftt6twagswzczad.onion/' && echo "HealthCheck succeeded..." || exit 1

USER tordocker

ENTRYPOINT ["tini", "--"]
CMD ["runsvdir", "/etc/service"]
