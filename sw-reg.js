/* SWI Regulatory (อย.) — Service Worker
   Its own cache, separate from the QA app's, so installing or updating one
   never evicts the other. Same strategy as sw.js:
   - App shell: cache-first with background refresh
   - Worker API: network-first with cached/offline fallback
*/
const CACHE_NAME = 'swi-reg-v1.0.0';
const APP_SHELL = [
  './regulatory.html',
  './registry.js',
  './reg-suite.js',
  './manifest-reg.webmanifest',
  './icon-192.png',
  './icon-512.png',
  './icon-512-maskable.png',
  './icon-180-apple.png',
  './favicon-32.png',
  './logo-swi.png',
  'https://cdn.tailwindcss.com',
  'https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Thai:wght@400;500;600;700&display=swap'
];

const API_HOSTS = ['swi-qa-api.swifoods.workers.dev'];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE_NAME)
      .then(c => c.addAll(APP_SHELL.map(u => new Request(u, { mode: 'no-cors' }))).catch(err => {
        console.warn('[SW-REG] precache failed:', err);
      }))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      // Only clean up this app's old caches — never the QA app's.
      .then(keys => Promise.all(keys.filter(k => k.startsWith('swi-reg-') && k !== CACHE_NAME).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);

  if (e.request.method !== 'GET') {
    e.respondWith(
      fetch(e.request).catch(() => new Response(
        JSON.stringify({ error: 'offline', queued: true }),
        { status: 503, headers: { 'Content-Type': 'application/json' } }
      ))
    );
    return;
  }

  if (API_HOSTS.includes(url.hostname)) {
    e.respondWith(
      fetch(e.request)
        .then(res => {
          const clone = res.clone();
          caches.open(CACHE_NAME).then(c => c.put(e.request, clone));
          return res;
        })
        .catch(() => caches.match(e.request).then(c => c || new Response(
          JSON.stringify({ error: 'offline', cached: false }),
          { status: 503, headers: { 'Content-Type': 'application/json' } }
        )))
    );
    return;
  }

  e.respondWith(
    caches.match(e.request).then(cached => {
      const fetchPromise = fetch(e.request).then(res => {
        if (res && res.status === 200) {
          const clone = res.clone();
          caches.open(CACHE_NAME).then(c => c.put(e.request, clone)).catch(()=>{});
        }
        return res;
      }).catch(() => cached);
      return cached || fetchPromise;
    })
  );
});

self.addEventListener('message', e => {
  if (e.data && e.data.type === 'SKIP_WAITING') self.skipWaiting();
});
