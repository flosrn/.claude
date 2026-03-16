# Security Review Checklist

## A01: Broken Access Control

- [ ] Authorization checks on EVERY endpoint (not just UI)
- [ ] Server-side enforcement (never trust client validation alone)
- [ ] IDOR protection: Verify users can't access other users' data by changing IDs
- [ ] No horizontal privilege escalation (same role bypassing isolation)
- [ ] No vertical privilege escalation (user → admin bypass paths)
- [ ] Default deny: Explicit allow required, not implicit
- [ ] Rate limiting on sensitive endpoints
- [ ] Token expiration and refresh token rotation

## A02: Cryptographic Failures

- [ ] Secrets not hardcoded (use env vars, secret manager)
- [ ] Sensitive data encrypted at rest and in transit
- [ ] No weak cryptography (MD5, SHA1 for passwords)
- [ ] No hardcoded API keys, tokens, or credentials
- [ ] HTTPS enforced (no fallback to HTTP)
- [ ] TLS 1.2+ only (no SSLv3, TLS 1.0)

## A03: Injection

- [ ] SQL queries parameterized (no string concatenation)
- [ ] Command injection prevention (no shell interpolation)
- [ ] Template injection prevention (no unsafe template rendering)
- [ ] XSS protection: Input sanitization, output encoding
- [ ] XXE prevention: XML parsers configured safely
- [ ] JSON deserialization safe (no arbitrary object creation)

## A05: Broken Access Control (API)

- [ ] API endpoints require authentication
- [ ] API endpoints enforce authorization
- [ ] CORS configured restrictively (not `*`)
- [ ] No sensitive data in query params (use POST body)
- [ ] No direct object references without validation
- [ ] Rate limiting per user/IP

## A06: Vulnerable Dependencies

- [ ] Regular dependency updates
- [ ] No known CVEs in lock file
- [ ] Transitive dependencies checked
- [ ] Dev dependencies not included in production builds

## A07: Identification & Auth

- [ ] Password minimum requirements (12+ chars recommended)
- [ ] No password reuse enforcement
- [ ] Brute force protection (rate limit, account lockout)
- [ ] Multi-factor authentication available (if sensitive)
- [ ] Session timeout configured
- [ ] No session fixation vulnerability

## A08: Data Integrity

- [ ] CSRF tokens on state-changing requests
- [ ] SameSite cookie attribute set
- [ ] No unvalidated redirects
- [ ] Serialization of untrusted data handled safely

## A09: Logging & Monitoring

- [ ] Failed login attempts logged
- [ ] Administrative actions logged
- [ ] No sensitive data logged (passwords, tokens, PII)
- [ ] Log access restricted
- [ ] Logs not stored with production data

## A10: SSRF Prevention

- [ ] No user-controlled URLs to backend services
- [ ] Internal IP ranges blocked (10.0.0.0/8, 172.16.0.0/12, etc.)
- [ ] Localhost/127.0.0.1 blocked
- [ ] DNS rebinding protections

## Search Patterns (to run)

```regex
# Hardcoded secrets
password.*=.*['"].*['"]
api[_-]?key.*=.*['"]
token.*=.*['"]
secret.*=.*['"]

# Dangerous functions
eval\(
exec\(
system\(
shell_exec\(
require\(.*\$
import\(.*\$

# SQL injection risks
query\(.*\+
execute\(.*\+
\.query\(.*f['"]
\.query\(.*`.*\${

# Disabled CORS
cors\(.*\*
Access-Control-Allow-Origin.*\*

# Hardcoded URLs
http://localhost
http://127.0.0.1
http://internal-
```

## Finding Format

For each finding:

```
[BLOCKING|CRITICAL|SUGGESTION] Category: What

Why: Risk explanation
How: Fix at file:line
Code: [snippet if needed]
```

**Only report findings you can point to** — no speculation.
