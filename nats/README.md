# NATS

This is the chart that we are installing: <https://github.com/nats-io/k8s/tree/main/helm/charts/nats>

Follow instructions [here](../tls-acme/README.md) to install kubectl, helm, and rancher.

Then add the nats helm repo:

```bash
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm repo update
```

Clone the `spin-helm` repo (`git clone https://github.com/NERSC/spin-helm.git`), and do the following:

```bash
cd spin-helm/nats/kustomize
# NOTE! you must set these
export SPIN_GID=<gid> # NERSC GID for the project
export SPIN_UID=<uid> # NERSC UID 
helm upgrade --install -n <your-namespace> nats nats/nats -f ../values.yaml --post-renderer ./kustomize.sh
```

This will render the script with the values.yaml file, and then patch in the required securityContext settings for the pods with kustomize.

This was tested with 1.2.2 version of NATS. For more values, you can look at <https://github.com/nats-io/k8s/blob/main/helm/charts/nats/values.yaml>.

There may be a more effective way of patching SPIN_GID and SPIN_UID from a configmap, but for the moment this works.
