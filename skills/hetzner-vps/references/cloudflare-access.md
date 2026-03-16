# Cloudflare Access (Zero Trust) Setup

Protect `*.ops.shipmate.bot` with email OTP authentication.

## Prerequisites

- Cloudflare account with `shipmate.bot` zone active
- Free plan (up to 50 users)

## Setup Steps

### 1. Enable Zero Trust

1. Go to https://one.dash.cloudflare.com/
2. Select your account
3. Navigate to **Access** → **Applications**

### 2. Create an Application

1. Click **Add an application** → **Self-hosted**
2. Application name: `OpenClaw Ops`
3. Session duration: `7 days`
4. Application domain: `*.ops.shipmate.bot`
5. Click **Next**

### 3. Configure Policy

1. Policy name: `Email allowlist`
2. Action: **Allow**
3. Include rule:
   - Selector: **Emails**
   - Value: `flo@youremail.com` (your email)
4. Click **Next** → **Add application**

### 4. Test

Visit any `*.ops.shipmate.bot` URL → you should see the Cloudflare Access login page → enter your email → receive OTP → access granted for 7 days.

## Authentication Methods

| Method | Setup | UX |
|--------|-------|----|
| **Email OTP** (default) | Zero setup | Enter email, receive code |
| Google SSO | Configure Google OAuth | One-click login |
| GitHub SSO | Configure GitHub OAuth | One-click login |
| One-time PIN | Same as email OTP | Same |

## Bypass for Specific Paths

If some paths need to be public (e.g., status page, webhooks):

1. Create a second application with the specific path
2. Set policy to **Bypass**

Example: `status.ops.shipmate.bot/api/status` → Bypass (for external monitoring)

## API Access (for scripts/bots)

Create a **Service Token** for automated access:

1. Access → Service Auth → Service Tokens
2. Create token
3. Use headers: `CF-Access-Client-Id` and `CF-Access-Client-Secret`

## Troubleshooting

- **Infinite redirect loop**: Check SSL/TLS mode is "Full (Strict)" in Cloudflare
- **Access page not showing**: DNS record must be proxied (orange cloud)
- **Can't receive OTP**: Check spam folder, or switch to Google SSO
