![TOR Privoxy Logo](https://i.imgur.com/rGdIzv9.png)

# torprivoxy

Run **Tor + Privoxy** in a single Docker container.

- `8118/tcp` → HTTP proxy (Privoxy)
- `9050/tcp` → SOCKS5 proxy (Tor)

## Images

Multi-architecture images are published for:

- `amd64`
- `arm64`
- `armv7`
- `armv6`

Tags:

- Alpine base: `ghcr.io/avpnusr/torprivoxy:latest`
- Debian base: `ghcr.io/avpnusr/torprivoxy:latest-debian`

> **Note:** If you run older Docker versions on armhf/Raspberry Pi, check Alpine `time64` migration notes:
> https://wiki.alpinelinux.org/wiki/Release_Notes_for_Alpine_3.13.0#time64_requirements

Build status:

![TorPrivoxy Docker Build](https://github.com/avpnusr/torprivoxy/workflows/TorPrivoxy%20Docker%20Build/badge.svg)

## Quick start

### Docker Compose

Use the included `docker-compose.yml` or this example:

```yaml
name: torprivoxy

services:
  torprivoxy:
    container_name: torprivoxy
    image: ghcr.io/avpnusr/torprivoxy:latest
    # image: ghcr.io/avpnusr/torprivoxy:latest-debian
    environment:
      TZ: Europe/Berlin # change to your timezone
      BRIDGE: |- 
        obfs4 <ip>:<port> <secret> cert=<cert> iat-mode=0
        obfs4 <ip>:<port> <secret> cert=<cert> iat-mode=0
    ports:
      - 8118:8118
      - 9050:9050
```

Start it:

```bash
docker compose up -d
```

### Docker run

Alpine image:

```bash
docker run -d \
  -p 8118:8118 \
  -p 9050:9050 \
  --user [UID:GID] \
  --name torprivoxy \
  --restart unless-stopped \
  ghcr.io/avpnusr/torprivoxy:latest
```

Debian image:

```bash
docker run -d \
  -p 8118:8118 \
  -p 9050:9050 \
  --user [UID:GID] \
  --name torprivoxy \
  --restart unless-stopped \
  ghcr.io/avpnusr/torprivoxy:latest-debian
```

## Configuration

### Default Tor behavior

Bridge relay is disabled by default:

```torrc
SOCKSPort 0.0.0.0:9050
ExitPolicy reject *:*
BridgeRelay 0
```

### Privoxy forwarding

Privoxy listens on `8118` and forwards to Tor on `9050`:

```privoxy
listen-address 0.0.0.0:8118
forward-socks5t / localhost:9050 .
```

### Using bridges (`BRIDGE` env)

If `BRIDGE` is set, the entrypoint appends:

- `UseBridges 1`
- `ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy`
- one `Bridge ...` line per `BRIDGE` line

Use a multiline environment value (as shown in the compose example).

## Healthcheck

The container includes a Docker `HEALTHCHECK` that verifies onion reachability via Privoxy by requesting DuckDuckGo’s `.onion` endpoint.

## Verify it works

HTTP proxy (Privoxy):

```bash
curl -x http://127.0.0.1:8118 https://check.torproject.org/
```

SOCKS5 proxy (Tor):

```bash
curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org/
```

## Credits

Kudos to [rdsubhas](https://hub.docker.com/r/rdsubhas/tor-privoxy-alpine) for inspiration around startup/service patterns.