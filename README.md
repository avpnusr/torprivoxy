![TOR Privoxy Logo](https://i.imgur.com/rGdIzv9.png)

**TOR and Privoxy in docker container**
===

This repository has multi architecture support and is regularly updated.    
Container is built for amd64, arm64, armv7 and armv6.

The container is available with alpine base image **ghcr.io/avpnusr/torprivoxy:latest**    
The container is also available with debian base image **ghcr.io/avpnusr/torprivoxy:latest-debian**

**Important:** Got rid of the old alpine version 3.12 - this could require action, if you use armhf architecture (Raspberry Pi i.e.) with older versions of docker. Please find information about this in the [alpine wiki](https://wiki.alpinelinux.org/wiki/Release_Notes_for_Alpine_3.13.0#time64_requirements)

Kudos to [rdsubhas](https://hub.docker.com/r/rdsubhas/tor-privoxy-alpine).   
I used the tini and run based startup-scripts for services from his container.

Status from last build
-----
![TorPrivoxy Docker Build](https://github.com/avpnusr/torprivoxy/workflows/TorPrivoxy%20Docker%20Build/badge.svg)

Versions in the latest image
-----
- [TOR](https://www.torproject.org/ "TOR Project Homepage") Version: 0.4.8.17
- [Privoxy](https://www.privoxy.org/ "Privoxy Homepage") Version: 4.0.0

Healthcheck & Configs
-----
The docker container has a working health-check built in.

To determine the correct function, it verifies access to the *.onion address from [DuckDuckGo](https://duckduckgo.com/ "DuckDuckGo Homepage").

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

**alpine version**
```
docker run -d \
  -p 8118:8118 \
  -p 9050:9050 \
  --user=[UID:GID] \
  --name torprivoxy \
  --restart=unless-stopped ghcr.io/avpnusr/torprivoxy
```

**debian version**
```
docker run -d \
  -p 8118:8118 \
  -p 9050:9050 \
  --user=[UID:GID] \
  --name torprivoxy \
  --restart=unless-stopped ghcr.io/avpnusr/torprivoxy:latest-debian
```
