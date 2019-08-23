FROM alpine:edge
MAINTAINER avpnusr

EXPOSE 8118 9050

RUN apk --update --no-cache add privoxy tor runit tini wget --repository http://dl-3.alpinelinux.org/alpine/edge/community/

COPY service /etc/service/

HEALTHCHECK --interval=120s --timeout=15s --start-period=120s --retries=2 \
            CMD wget --no-check-certificate -e use_proxy=yes -e https_proxy=127.0.0.1:8118 --quiet --spider 'https://3g2upl4pq6kufc4m.onion' && echo "HealthCheck succeeded..." || exit 1

ENTRYPOINT ["tini", "--"]
CMD ["runsvdir", "/etc/service"]
