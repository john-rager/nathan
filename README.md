# nathan

Mobile-first PWA to view n8n workflows and executions.

Run (web):

```bash
flutter run -d chrome --web-port=8090
```

Build (release web):

```bash
flutter build web --release --wasm
```

Notes:
- Configure instances in Settings. The app saves instances and last selected instance locally.
- When adding an instance, set the URL to the root of your n8n instance (example: https://n8n.example.com) and paste the API key into the API Key field.
- **CORS**: The app makes cross-origin requests to your n8n instance. Use a Cloudflare Worker to handle CORS for both development and production:

### Setup Cloudflare Worker (One-time)

1. Go to your Cloudflare dashboard → **Workers** → **Create a Service**
2. Name it `n8n-cors` and click **Create Service**
3. Click **Quick Edit** and replace the code with the script below
4. Click **Save and Deploy**
5. Go to **Triggers** → **Routes** → **Add Route**
6. Add route: `n8n-oci.mikadataservices.com/api/*` (or your n8n domain)
7. Select the `n8n-cors` worker
8. Click **Save**
9. Test: refresh your app at `http://localhost:8090` — workflows should load

**Worker Script:**
```js
addEventListener('fetch', event => {
  event.respondWith(handle(event.request));
});

async function handle(request) {
  const origin = request.headers.get('Origin') || '';
  // Add your production domain when deployed
  const corsAllowed = ['http://localhost:8090', 'https://your-github-pages-domain.com'];
  const allowOrigin = corsAllowed.includes(origin) ? origin : corsAllowed[0];

  // Handle preflight (OPTIONS) requests
  if (request.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': allowOrigin,
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS, PUT, DELETE',
        'Access-Control-Allow-Headers': 'X-N8N-API-KEY, Content-Type, Authorization',
        'Access-Control-Max-Age': '3600'
      }
    });
  }

  // Forward non-OPTIONS requests to origin
  const resp = await fetch(request);
  const newHeaders = new Headers(resp.headers);
  newHeaders.set('Access-Control-Allow-Origin', allowOrigin);
  return new Response(resp.body, {
    status: resp.status,
    statusText: resp.statusText,
    headers: newHeaders
  });
}
```

After deploying the Worker, refresh your app and you should see workflows and executions loading.
