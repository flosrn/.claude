# Security — 4 Layers

## Layer 1: Hetzner Cloud Firewall (network level)

Applied at Hetzner infrastructure level, before packets reach the VPS.

| Rule | Protocol | Port | Source |
|------|----------|------|--------|
| SSH | TCP | 22 | 0.0.0.0/0 |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| HTTPS | TCP | 443 | 0.0.0.0/0 |
| Mosh | UDP | 60000-61000 | 0.0.0.0/0 |
| All outbound | * | * | — |

## Layer 2: UFW + DOCKER-USER (host level)

UFW is configured but Docker bypasses it via the FORWARD chain. The `DOCKER-USER` iptables chain provides the real filtering for Docker-published ports.

## Layer 3: CrowdSec (application level)

- Image: `crowdsecurity/crowdsec:latest`
- Proactive IDS/IPS with collective intelligence (~1M IPs/day)
- Collections: `linux`, `sshd`, `traefik`, `http-cve`, `base-http-scenarios`, `whitelist-good-actors`
- Reads `/var/log` from host (read-only)
- LAPI exposed on `127.0.0.1:8080` (for firewall bouncer)
- **Traefik bouncer**: `fbonalair/traefik-crowdsec-bouncer` — forward-auth middleware, checks every HTTP request
- **Firewall bouncer**: `crowdsec-firewall-bouncer-nftables` (host) — blocks IPs at nftables level

### Layer 3b: Docker Socket Proxy

- Image: `wollomatic/socket-proxy:1`
- Runs as `user: "0:988"` (Docker GID)
- Allows: GET containers/images, POST images/create + containers start/stop/restart, DELETE containers
- Blocks: exec, build, volumes, privileged
- Network: `security` (isolated)

## Layer 4: Tailscale (admin access)

- Tailscale IP: `100.77.103.17`
- Hostname: `openclaw-prod`
- All admin interfaces via `*.ops.shipmate.bot` (public, Cloudflare Access not yet active)
- Secondary secure access for SSH and direct service access

## SSH Config

- Key-only authentication (ed25519)
- `PermitRootLogin prohibit-password`
- `MaxAuthTries 3`
- Strong ciphers: chacha20-poly1305, aes256-gcm
- Mosh enabled (UDP 60000-61000) for low-latency from Bangkok

## Docker Socket Security

The Docker socket is NEVER mounted directly in application containers.

```
openclaw-gateway → oc-ops (sidecar) → wollomatic/socket-proxy → docker.sock
                   (REST API)         (regex whitelist)
```

wollomatic allows only:
- GET: `/_ping`, `/containers/json`, `/containers/{id}/json`, `/images/json`
- POST: `/images/create` (pull), `/containers/{id}/(start|stop|restart)`, `/containers/create`
- DELETE: `/containers/{id}` (remove old)
- BLOCKED: `exec`, `build`, `volumes`, `privileged`
