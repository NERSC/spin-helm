# Repository Guidelines

This guide explains how to contribute to the Spin Helm recipes with minimal friction. Keep changes small, tested, and documented so others can reproduce them.

## Project Structure & Module Organization
- `nats/`: Helm values and kustomize post-renderer for the NATS chart; `values.yaml` for defaults and `tls-acme-values.yaml` for certificate setup. `kustomize/` patches StatefulSets/Deployments with `SPIN_UID`/`SPIN_GID`.
- `tls-acme/`: Standalone Helm chart (`Chart.yaml`, `templates/`, `values.yaml`) for ACME-driven TLS issuance and renewals on Spin.
- `scripts/`: Utility scripts (e.g., `scripts/mdl.sh` for markdownlint autofix).
- Repo configs: `.pre-commit-config.yaml`, `.yamllint.yml`, `.markdownlint.rb` define lint rules; align contributions to them.

## Build, Test, and Development Commands
- `pre-commit run --all-files` to run markdownlint, yamllint, and trailing whitespace checks locally.
- `yamllint .` to validate YAML with the repo config (line length 120, strict indentation).
- `./scripts/mdl.sh` to autofix Markdown formatting before review.
- `helm lint tls-acme` to sanity-check the TLS chart; add `-f <values>` as needed.
- For NATS overlays, render and patch locally: `cd nats/kustomize && helm template nats/nats -f ../values.yaml --post-renderer ./kustomize.sh`.

## Coding Style & Naming Conventions
- YAML: 2-space indentation, descriptive keys, keep `*-values.yaml` file names and placeholder tokens (`RUN_AS_USER_PLACEHOLDER`, `FS_GROUP_PLACEHOLDER`) intact for scripted substitution.
- Markdown: respect `.markdownlint.rb` (ordered lists, generous line length). Prefer short headings and actionable steps.
- Shell: keep scripts POSIX/Bash compatible, check for required env vars (`SPIN_UID`, `SPIN_GID`) before use.

## Testing Guidelines
- Chart changes: run `helm lint` and, when altering templates, `helm template ... | kubectl kustomize ./nats/kustomize` to verify patches apply cleanly.
- Functional checks occur on Spin: follow the per-directory READMEs to install/upgrade releases, then validate via `kubectl` execs (e.g., `nats rtt`) or ingress reachability.
- Add brief notes in PRs on what was verified (commands + namespace/cluster used), especially for TLS issuance runs.

## Commit & Pull Request Guidelines
- Commits: imperative mood with scope when helpful (e.g., `nats: adjust websocket ingress whitelist`); group related changes.
- PRs: include a summary of changes, linked issues (if any), values files touched, commands run, and relevant logs or screenshots for install/upgrade attempts.
- Avoid committing secrets or cluster-specific kubeconfigs; keep sensitive values in local overrides and document placeholders instead.
