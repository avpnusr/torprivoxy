![TOR Privoxy Logo](https://www.foxplex.com/components/uploads/VIGfbsoj-tor_proxy_raspberry_splash.png)

**TOR and Privoxy in docker container**
===

Image is built on docker infrastructure for x86 systems.

Image is built on TinkerBoard or Raspberry Pi for ARM systems.

Find the suitable version for you in the [tags](https://hub.docker.com/r/avpnusr/torprivoxy/tags).

Kudos to [rdsubhas](https://hub.docker.com/r/rdsubhas/tor-privoxy-alpine) I used the tini and run based startup for services from his container.

Versions in the latest image
-----
- [TOR](https://www.torproject.org/ "TOR Project Homepage") Version: 0.3.5.8
- [Privoxy](https://www.privoxy.org/ "Privoxy Homepage") Version: 3.0.28

Healthcheck & Configs
-----
The container has a working healtcheck built in.

**torrc-configuration:**
```
SOCKSPort 0.0.0.0:9050
ExitPolicy reject *:*
BridgeRelay 0
```
I know the TOR-Project is in need for bridge relays, but considering, not every user from the container is familiar with the impacts, I decided to disable the bridge relay in the container by default.

**privoxy-configuration:**
```
listen-address 0.0.0.0:8118
forward-socks5t / localhost:9050 .
```

Start your container
-----
On port **[8118]**, the container offers a privoxy HTTP-Proxy forwarded to localhost:9050 SOCKS5

On port **[9050]**, the container offers the TOR SOCKS5 proxy

```
docker run -d \
  -p 8118:8118 \
  -p 9050:9050 \
  --restart=always avpnusr/torprivoxy
```
