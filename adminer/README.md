# Adminer

Adminer is a lightweight, single-file web UI for managing databases such as
PostgreSQL. This chart deploys Adminer in your Spin namespace.

## Install

```bash
helm install -n <namespace> <release-name> .
```

## Configure

Edit `values.yaml` before installing or upgrading.

- `env.ADMINER_DEFAULT_SERVER`: default database host shown in the Adminer UI
  (e.g. the PostgreSQL Service name like `postgres` or `postgresql`).
- `env.ADMINER_DESIGN`: UI theme (default `pepa-linha`).
- `service.port`: Adminer listens on 8080 by default.

## Access after deployment

With `service.type: ClusterIP`, use port-forwarding:

```bash
kubectl -n <namespace> port-forward svc/<release-name>-adminer 8080:8080
```

Then open `http://127.0.0.1:8080` in a browser.

If you want external access, add an Ingress (not included in this chart).
