![TOR Privoxy Logo](https://i.imgur.com/rGdIzv9.png)

**TOR and Privoxy in docker container**
===

This repository has multi architecture support and is regularly updated.    
Container is built for amd64, arm and arm64.

Kudos to [rdsubhas](https://hub.docker.com/r/rdsubhas/tor-privoxy-alpine).   
I used the tini and run based startup for services from his container.

Versions in the latest image
-----
- [TOR](https://www.torproject.org/ "TOR Project Homepage") Version: 0.4.2.7-r0
- [Privoxy](https://www.privoxy.org/ "Privoxy Homepage") Version: 3.0.28

Healthcheck & Configs
-----
The docker container has a working healthcheck built in.

To determine the correct function, it verifies access to some *.onion addresses.

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
  --user=[UID:GID] \
  --name torprivoxy \
  --restart=unless-stopped avpnusr/torprivoxy
```
