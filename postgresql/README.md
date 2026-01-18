# PostgreSQL Helm Chart

This chart deploys PostgreSQL on Spin. Update the placeholders in
`values_template.yaml`, or use the helper script to generate `values.yaml`.

## Prerequisites

- `kubectl` and `helm` installed
- Access to a Spin namespace and its kubeconfig

See `tls-acme/README.md` for installation steps for kubectl/helm and kubeconfig.

## Configure values

1. Edit `postgresql/prepare-values.sh` with your settings.
2. Generate a rendered values file:

```bash
./prepare-values.sh
```

This writes `values.yaml` (or a custom path if you pass one).

## Quick start

```bash
cd postgresql
./prepare-values.sh
helm lint .
helm install -n <namespace> <release-name> .
```

## Install

```bash
helm install -n <namespace> <release-name> .
```

## Upgrade or uninstall

```bash
helm upgrade -n <namespace> <release-name> .
helm uninstall -n <namespace> <release-name>
```

## Notes

- Persistent volume size is controlled by `persistentVolumeClaims.<deployment_name>.size` (where `deployment_name` defaults to `psql` in `prepare-values.sh`).
- Liveness and readiness probes use `pg_isready` with the configured database name and user.
