# replit_ui docs

The documentation site for [replit_ui](https://github.com/asimawdah/replit_ui),
built with [Astro Starlight](https://starlight.astro.build).

```bash
npm install
npm run dev      # http://localhost:4321
npm run build    # static site in dist/
```

Google Sans loads from Google Fonts via the `<link>` in `astro.config.mjs`,
for this site's own chrome — the package bundles its own copy. Brand colors in
`src/styles/theme.css` mirror the package's design tokens in
`packages/replit_ui/lib/src/theme/replit_colors.dart`.

`npm run playground` builds the repo's `playground/` Flutter app for the
web into `public/playground/` — served at `/playground/<component>` (path
URLs, one per component) and embedded on component pages as live demos via
`src/components/ReplitDemo.astro`
(`/playground/index.html?embed=<demo>&variant=<v>&theme=<light|dark>`).
`npm run build:site` chains playground + docs into one `dist/`.

The site is deployable to Cloudflare Pages. The Wrangler configuration uses
`dist/` as the Pages output directory; deploy from this directory after
installing the npm dependencies and ensuring Flutter is available:

```bash
npm run deploy:pages
```

Create a Cloudflare Pages project named `replit-ui` first, or change `name`
in `wrangler.jsonc` to match your existing Pages project. Authenticate with
Wrangler beforehand using `npx wrangler login`.

The playground component paths are routes inside the app, not files. The
explicit rules in `public/_redirects` keep deep links working on Cloudflare
Pages, and `public/_headers` enables cross-origin isolation for the standalone
playground so its multithreaded Wasm renderer can run. The
`playground-dev-index` integration in `astro.config.mjs` handles the routes
for `npm run dev`.

Planned: `dart doc` output under `public/api/`.
