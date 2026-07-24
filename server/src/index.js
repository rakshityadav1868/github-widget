/**
 * GitHub Widget - OAuth token-exchange backend (Cloudflare Worker).
 *
 * The mobile app sends the authorization `code` it got from GitHub; this
 * worker exchanges it for an access token using the client secret, which
 * lives ONLY here (as a Worker secret) - never in the app or the repo.
 *
 * POST /  { "code": "..." }  ->  { "access_token": "...", "scope": "...", ... }
 */
export default {
  async fetch(request, env) {
    const cors = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: cors });
    }
    if (request.method !== 'POST') {
      return json({ error: 'method_not_allowed' }, 405, cors);
    }

    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: 'invalid_json' }, 400, cors);
    }

    const code = body.code;
    if (!code) {
      return json({ error: 'missing_code' }, 400, cors);
    }

    const ghResponse = await fetch('https://github.com/login/oauth/access_token', {
      method: 'POST',
      headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
      body: JSON.stringify({
        client_id: env.GITHUB_CLIENT_ID,
        client_secret: env.GITHUB_CLIENT_SECRET,
        code,
      }),
    });

    const data = await ghResponse.json();
    if (data.error) {
      return json({ error: data.error, description: data.error_description }, 400, cors);
    }

    return json(
      {
        access_token: data.access_token,
        scope: data.scope,
        token_type: data.token_type,
      },
      200,
      cors,
    );
  },
};

function json(obj, status, cors) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { 'Content-Type': 'application/json', ...cors },
  });
}
