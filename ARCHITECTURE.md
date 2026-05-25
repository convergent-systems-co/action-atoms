# Architecture

(Replace this stub. See `docs/adr/` for individual decisions.)

## Repository layout

```
web/                    Front-end site
atoms/                  Atom YAML files, one per action
  github/               GitHub Actions atoms
composite/              Actual composite action implementations
exports/                CI-generated machine-readable exports
infra/                  Infrastructure-as-code
docs/                   Project documentation
  adr/                  MADR-format architecture decisions
```
