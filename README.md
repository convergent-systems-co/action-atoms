# action-atoms

> Atomic CI actions catalog — one step's worth of work.

Part of the Convergent Systems atoms ecosystem. This is one of three
sibling registries for GitHub Actions atoms, matching how GitHub
itself layers the primitives:

| Layer | Registry | What it is |
|---|---|---|
| **Action** (this repo) | `action-atoms.com` | One step's worth of work — composite, JS, or Docker action |
| **Workflow** | `workflow-atoms.com` | One job's worth — reusable workflow, composes actions |
| **Pipeline** | `pipeline-atoms.com` | Top-level workflow that composes other workflows |

Spec: [`SPEC.md §7.11`](https://github.com/convergent-systems-co/aiConstitution/blob/main/SPEC.md#711-action-workflow-and-pipeline-atoms--the-github-actions-trinity-v010)
in the `aiConstitution` repo (v0.10).

## Layout

```
composite/                       # GitHub composite actions
└── cs-page-deployment/
    └── action.yml
javascript/                      # GitHub JavaScript actions (none yet)
docker/                          # GitHub Docker actions (none yet)
```

Each subdirectory is a GitHub-consumable action. Versioning is git
tags on this repo — `cs-page-deployment@v1.0.0` is the tag `v1.0.0`
pointing at the `composite/cs-page-deployment/` content.

## Canonical identity vs consumption form

Per the spec, every atom has two equivalent references:

```
canonical: https://action-atoms.com/github/composite/cs-page-deployment@1.0.0
                                          (browse / catalog / CLI form)
uses:      convergent-systems-co/action-atoms/composite/cs-page-deployment@v1.0.0
                                          (what GHA actually resolves)
```

GHA's `uses:` grammar cannot resolve an HTTPS URL, so the
`https://action-atoms.com/...` form is for humans + the
catalog; this repo + git tags are what `uses:` reaches at runtime.
The `ai action install` CLI accepts the canonical URL and writes the
`uses:` form into `.github/workflows/<file>.yml` for you.

## Available atoms

### `cs-page-deployment` (composite)

Builds an Astro / Node site and deploys to Cloudflare Pages via
`wrangler@4 pages deploy`. Wraps the steps that previously lived
inline in every Convergent Systems site's deploy workflow.

**Usage** in `.github/workflows/<deploy>.yml`:

```yaml
name: Deploy <site-name>
on:
  push:
    branches: [main]
    paths: ['web/<site-name>/**', '.github/workflows/deploy-<site-name>.yml']
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: pages-<site-name>
  cancel-in-progress: false

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://<custom-domain>
    env:
      CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
      CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
    steps:
      - uses: actions/checkout@v6
      - uses: convergent-systems-co/action-atoms/composite/cs-page-deployment@v1.0.0
        with:
          site-dir: web/<site-name>
          project-name: <pages-project-name>
          branch: main          # "main" → production; anything else → preview
          # node-version: '22'  # default; Astro 6 requires >= 22.12
```

**Inputs:**

| Input | Required | Default | Description |
|---|---|---|---|
| `site-dir` | yes | — | Path (relative to repo root) of the site directory containing `package.json`. |
| `project-name` | yes | — | Cloudflare Pages project name (created by terraform; see SPEC §7.11). |
| `branch` | no | `main` | Branch label for the deploy. `"main"` marks the deploy as production; anything else creates a preview URL. |
| `node-version` | no | `22` | Node version. Astro 6 requires ≥ 22.12. |

**Required env / secrets** (set on the caller workflow):

- `CLOUDFLARE_API_TOKEN` — Cloudflare API token scoped Account →
  Cloudflare Pages → Edit.
- `CLOUDFLARE_ACCOUNT_ID` — the Convergent Systems CF account id.

## Contributing

Open an `action` issue on this repo proposing the new atom; PR the
content under `composite/<name>/` (or `javascript/<name>/`,
`docker/<name>/`). Atoms get tagged at the repo level — the next
release tag picks up every new atom in the tree.

Per the spec's immutability invariant: once published at a version,
an atom is **never mutated at that version**. Improvements ship as
new versions; users opt in.

## License

This catalog is dual-licensed per the `*-atoms` ecosystem convention:

- **Code:** Apache-2.0 — see [`LICENSE`](./LICENSE).
- **Data / catalog content:** CC-BY-4.0 — see [`LICENSE-data`](./LICENSE-data).
