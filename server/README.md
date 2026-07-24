# GitHub Widget — auth backend

A tiny Cloudflare Worker that exchanges a GitHub OAuth `code` for an access
token. The **client secret lives only here** (as a Worker secret), never in
the app or the repo — that's the whole point of having a backend.

## Deploy (free, ~5 minutes)

You need a free [Cloudflare account](https://dash.cloudflare.com/sign-up).

From this `server/` folder:

```bash
npx wrangler login
npx wrangler secret put GITHUB_CLIENT_SECRET
npx wrangler deploy
```

- `wrangler login` opens the browser to authorize (one time).
- `secret put` prompts you to paste the **client secret** — generate it in your
  GitHub OAuth App (https://github.com/settings/developers → your app →
  "Generate a new client secret"). It's stored encrypted on Cloudflare only.
- `deploy` prints a URL like `https://github-widget-auth.<you>.workers.dev`.

Give that URL to put in the app (`lib/core/config.dart` → `authBackendUrl`).

## GitHub OAuth App settings

Set the **Authorization callback URL** to:

```
githubwidget://callback
```

(Device Flow can stay enabled or off — it's no longer used.)

## Test it

```bash
curl -X POST https://github-widget-auth.<you>.workers.dev \
  -H 'Content-Type: application/json' -d '{"code":"test"}'
# -> {"error":"bad_verification_code"}  (means it's reachable and wired up)
```
