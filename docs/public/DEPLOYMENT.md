# StudyLoop public policy pages

Canonical source is `docs/public/studyloop/{privacy,support}/index.html`. These are standalone bilingual pages without scripts, external fonts or analytics. Matching copies live in the personal website checkout at `nextjs/public/studyloop/`, so a future Next.js export includes them.

On September 30, 2026 the pages were added to the existing served release under `/opt/sites/personal-website/current/studyloop/`; no existing page was replaced. After explicit owner approval, the `qling.it.com` block gained this matcher before its existing generic fallback:

```caddyfile
@studyloop path /studyloop/*
try_files @studyloop {path} {path}index.html {path}/index.html =404
```

The candidate configuration passed `caddy validate`. The existing config file was updated in place so its Docker mount remained valid, then Caddy was reloaded. Other site blocks and DNS were preserved. Backup: `/opt/chinese-chess/deploy/Caddyfile.pre-studyloop-20260930`.

Public browser verification confirms real StudyLoop titles/content at both URLs, with no horizontal overflow. The support page was visually checked at phone width and the privacy page at desktop width. Mail and repository links are present; inbox delivery is not independently tested. Retain the scoped matcher and page files in future deployments. Any further server configuration change requires owner approval under the site's deployment instructions.
