# Traefik Label Patterns

Common label configurations for Docker Compose services behind Traefik v3.

## Basic HTTPS Service

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.SERVICENAME.rule=Host(`SERVICENAME.ops.shipmate.bot`)"
  - "traefik.http.routers.SERVICENAME.entrypoints=websecure"
  - "traefik.http.routers.SERVICENAME.tls.certresolver=cloudflare"
  - "traefik.http.services.SERVICENAME.loadbalancer.server.port=PORT"
```

## With Middleware (rate-limit + secure headers)

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.SERVICENAME.rule=Host(`SERVICENAME.ops.shipmate.bot`)"
  - "traefik.http.routers.SERVICENAME.entrypoints=websecure"
  - "traefik.http.routers.SERVICENAME.tls.certresolver=cloudflare"
  - "traefik.http.routers.SERVICENAME.middlewares=secure-headers@file,rate-limit@file"
  - "traefik.http.services.SERVICENAME.loadbalancer.server.port=PORT"
```

## With Basic Auth

```yaml
labels:
  - "traefik.http.routers.SERVICENAME.middlewares=auth@file"
```

The auth middleware is defined in `/opt/docker/traefik/config/middlewares.yml`.

## WebSocket Support

```yaml
labels:
  - "traefik.http.services.SERVICENAME.loadbalancer.server.scheme=http"
  - "traefik.http.middlewares.SERVICENAME-headers.headers.customrequestheaders.X-Forwarded-Proto=https"
```

## Path-Based Routing

```yaml
labels:
  - "traefik.http.routers.SERVICENAME.rule=Host(`ops.shipmate.bot`) && PathPrefix(`/api`)"
  - "traefik.http.middlewares.SERVICENAME-strip.stripprefix.prefixes=/api"
  - "traefik.http.routers.SERVICENAME.middlewares=SERVICENAME-strip"
```

## Health Check

```yaml
labels:
  - "traefik.http.services.SERVICENAME.loadbalancer.healthcheck.path=/health"
  - "traefik.http.services.SERVICENAME.loadbalancer.healthcheck.interval=30s"
```

## Current Services

| Service | Router name | Port | URL |
|---------|-------------|------|-----|
| Grafana | grafana | 3000 | grafana.ops.shipmate.bot |
| Beszel | beszel | 8090 | beszel.ops.shipmate.bot |
| Uptime Kuma | uptime-kuma | 3001 | status.ops.shipmate.bot |
| Dozzle | dozzle | 8080 | logs.ops.shipmate.bot |
| ntfy | ntfy | 8091 | ntfy.ops.shipmate.bot |
| Clawmetry | clawmetry | 8900 | clawmetry.ops.shipmate.bot |
| Traefik dashboard | traefik | 8080 | traefik.ops.shipmate.bot |
| OpenClaw gateway | openclaw | 18789 | gateway.ops.shipmate.bot |
