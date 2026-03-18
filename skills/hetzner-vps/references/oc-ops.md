# Self-Update — Sidecar Operator (oc-ops)

## The Problem

A container cannot safely restart itself — the process dies before the new container is created (race condition).

## The Solution

`oc-ops` is a lightweight sidecar that survives during updates:

```
Agent POST /self-update → oc-ops pulls new image → oc-ops recreates gateway
                          (sidecar stays alive)     → new gateway starts
                                                    → healthcheck passes
                                                    → done
```

## API Endpoints

| Method | Endpoint | Action |
|--------|----------|--------|
| POST | `/self-update` | Pull + recreate openclaw-gateway |
| POST | `/containers/{name}/start` | Start a named container |
| POST | `/containers/{name}/stop` | Stop a named container |
| POST | `/containers/{name}/restart` | Restart a named container |
| POST | `/rebuild` | Build from Dockerfile + recreate |
| GET | `/containers` | List all containers + status |
| GET | `/health` | Sidecar health |

Auth: `X-Ops-Token` header required on all endpoints.
Token in `/opt/docker/openclaw/.env` as `OPS_TOKEN`.

## Usage

```bash
TOKEN=$(grep OPS_TOKEN /opt/docker/openclaw/.env | cut -d= -f2)

# Health
curl -H "X-Ops-Token: $TOKEN" http://127.0.0.1:8400/health

# List containers
curl -H "X-Ops-Token: $TOKEN" http://127.0.0.1:8400/containers

# Restart a container
curl -X POST -H "X-Ops-Token: $TOKEN" http://127.0.0.1:8400/containers/openclaw-gateway/restart

# Self-update (pull + recreate gateway)
curl -X POST -H "X-Ops-Token: $TOKEN" http://127.0.0.1:8400/self-update
```
