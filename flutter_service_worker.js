'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"icons/Icon-512.png": "f03565ba3c3f129b124c7bc43ff9852e",
"icons/Icon-maskable-512.png": "f03565ba3c3f129b124c7bc43ff9852e",
"icons/Icon-192.png": "7a813391001d7be59bf9358fa5698182",
"icons/Icon-maskable-192.png": "7a813391001d7be59bf9358fa5698182",
"manifest.json": "3fe05f9973f0af97a79d457864ec5eca",
"index.html": "a5fbd30a960cdcee940bc807190d37ab",
"/": "a5fbd30a960cdcee940bc807190d37ab",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "8aa2de2c70fa2abd8037d70e513b7431",
"assets/assets/icons/home.svg": "b62e4e0c221af38ccadc3889c508ee1a",
"assets/assets/icons/news_highlighted.svg": "357a36266f4c4ccff0171ecff46aadfc",
"assets/assets/icons/chat.svg": "e6e02c570c633cdc9df525450f67dc4c",
"assets/assets/icons/account_highlighted.svg": "2f54b1a64389f5d2f8ba593d62e96a39",
"assets/assets/icons/news.svg": "470bc24ce7a3adad101e188ca4ad5121",
"assets/assets/icons/account.svg": "a474ef4e352692304a54dfbe8266bf60",
"assets/assets/icons/arrow_back.svg": "dd470e8c3e860c5adf8af183f743aba3",
"assets/assets/icons/verified.svg": "14d95a4253bc40335a44f508d15e90df",
"assets/assets/icons/search.svg": "2d0c045fcf8b010268db7fda4240a451",
"assets/assets/icons/search_highlighted.svg": "c8774f963e52dc0d26c2b8115e25312f",
"assets/assets/icons/community_highlighted.svg": "a58f06dd510f75544dd8c0ae575ba915",
"assets/assets/icons/trash.svg": "f88179ccc3649c47f2264315be6c0421",
"assets/assets/icons/favorite.svg": "831c947d4833902800003bd6b59b1d8c",
"assets/assets/icons/morePoints.svg": "ce3b1c0ae59df0a0c3ec3349de8e9d9a",
"assets/assets/icons/community.svg": "64b38d3aa6200df47d8c29a709d7df63",
"assets/assets/icons/morePoints_highlighted.svg": "b872d89b69de5c91b4a791167362cb48",
"assets/assets/icons/favorite_active.svg": "ca88704e3af77c471f6077feb48c4dff",
"assets/assets/icons/home_highlighted.svg": "686e5701e352874478c4523a7901d81b",
"assets/assets/app_logo/inner_circle_logo_highlighted.svg": "51198569e99ee3ec0de8dba2223de8f3",
"assets/assets/app_logo/inner_circle_logo.svg": "ebfb999bdaec30261efaa18762db3a51",
"assets/assets/app_logo/app_icon.png": "6c9543fe2c52d1c84a1e2b20a5c6ba47",
"assets/fonts/MaterialIcons-Regular.otf": "9c17dc5e6c2655f6e3a8857e6ad4826f",
"assets/NOTICES": "0a7e16442055a30a4ffeba5b263ee4b1",
"assets/packages/flutter_image_compress_web/assets/pica.min.js": "6208ed6419908c4b04382adc8a3053a2",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin": "9655505105b4c0f1a9205ea1d503b7e2",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"favicon.png": "84d52e6cbafeb38034a1855a738fc296",
"apple-touch-icon.png": "ac65f94233514ec07485de261d2df460",
"404.html": "b59a208ae618752cbbfd03827cc81f02",
"flutter_bootstrap.js": "2f2e09a954bd6862634ed4e8bc279779",
"version.json": "f5b34f776e561c70dead7a5b7a7bace0",
"main.dart.js": "f2e19d5e7e0c5f5f000ff737ca984b92"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
