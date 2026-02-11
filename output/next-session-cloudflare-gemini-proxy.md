# Cloudflare Worker Proxy for Gemini API

## Context
Le VPS RackNerd (Santa Clara, CA) est blacklisté par Google Gemini API ("User location is not supported") car ColoCrossing/RackNerd IPs sont bloquées. La clé API fonctionne depuis un réseau résidentiel mais pas depuis le datacenter.

## Solution
Déployer un Cloudflare Worker comme proxy qui relaie les appels Gemini API via le réseau edge Cloudflare (non-blacklisté).

## Prérequis
- Compte Cloudflare (gratuit) : https://dash.cloudflare.com/sign-up
- Clé Gemini API : `AIzaSyCtnJcpRRBo8RYQsD_kxOrH8aFTyPnekTs`
- `npm install -g wrangler` (CLI Cloudflare)

## Plan d'exécution

### Step 1 : Créer le Worker
Créer un Cloudflare Worker qui :
- Reçoit les requêtes vers `https://<worker>.workers.dev/v1beta/*`
- Injecte la clé API Gemini (stockée en secret, pas en dur)
- Forward la requête vers `https://generativelanguage.googleapis.com/v1beta/*`
- Retourne la réponse

```javascript
export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // Health check
    if (url.pathname === '/') {
      return new Response('OK', { status: 200 });
    }

    // Build target URL
    const targetUrl = `https://generativelanguage.googleapis.com${url.pathname}${url.search}`;

    // Clone request and add API key
    const modifiedUrl = new URL(targetUrl);
    modifiedUrl.searchParams.set('key', env.GEMINI_API_KEY);

    const modifiedRequest = new Request(modifiedUrl.toString(), {
      method: request.method,
      headers: request.headers,
      body: request.body,
    });

    return fetch(modifiedRequest);
  },
};
```

### Step 2 : Déployer
```bash
# Login Cloudflare
wrangler login

# Créer le projet
mkdir gemini-proxy && cd gemini-proxy
wrangler init --yes

# Écrire le worker (src/index.js)
# Écrire wrangler.toml

# Ajouter la clé API en secret
wrangler secret put GEMINI_API_KEY
# -> Entrer : AIzaSyCtnJcpRRBo8RYQsD_kxOrH8aFTyPnekTs

# Déployer
wrangler deploy
```

### Step 3 : Tester
```bash
# Depuis le VPS
ssh vps 'curl -s "https://gemini-proxy.<account>.workers.dev/v1beta/models/gemini-embedding-001:embedContent" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"models/gemini-embedding-001\",\"content\":{\"parts\":[{\"text\":\"test\"}]}}"'
```

### Step 4 : Configurer OpenClaw
Mettre à jour la config OpenClaw sur le VPS pour utiliser le proxy au lieu de l'API Gemini directe.

Chercher dans `~/.openclaw/openclaw.json` la config embeddings et remplacer l'URL de base :
- Avant : `https://generativelanguage.googleapis.com`
- Après : `https://gemini-proxy.<account>.workers.dev`

Puis `docker compose restart openclaw-gateway`

### Step 5 : Vérifier
Tester `memory_search` depuis Telegram pour confirmer que les embeddings fonctionnent.

## Limites Cloudflare Workers (plan gratuit)
- 100,000 requêtes/jour
- 10ms CPU time par requête (largement suffisant pour un proxy)
- Pas de coût supplémentaire
