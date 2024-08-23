# NATS

## Installing NATS Helm

This is the chart that we are installing: <https://github.com/nats-io/k8s/tree/main/helm/charts/nats>. You can look here to find out more about this chart, and feel free to add whatever you'd like to [values.yaml](./values.yaml).

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
helm upgrade --install -n <your-namespace> nats nats/nats --version 1.2.2 -f ../values.yaml --post-renderer ./kustomize.sh
```

This will render the script with the values.yaml file, and then patch in the required securityContext settings for the pods with kustomize.

This was tested with 1.2.2 version of NATS. For more values, you can look at <https://github.com/nats-io/k8s/blob/main/helm/charts/nats/values.yaml>.

There may be a more effective way of patching SPIN_GID and SPIN_UID from a configmap, but for the moment this works.

## Testing to see if things are set up

To test, you can do the following:

```bash
kubectl exec -n nats-helm-test -it deployment/nats-box -- nats rtt
# > nats://nats:
#
#   nats://10.43.124.110:4222: 123.477µs
```

## Making remote connections

### Connections from within NERSC Network

Doing the above will enable you to access your NATS cluster from other services in the cluster. To access your NATS jetstream cluster remotely from inside NERSC, you can uncomment the `extraResources`, which will set up a load balancer. NATS typically uses port 4222 to communicate, but we do not allow that TCP port on Spin. We set the externally facing port to `5672`, and the target to `4222`.

After uncommenting this, you should be able to upgrade (see above), and then test from a login node by installing the [NATS CLI tool](https://docs.nats.io/running-a-nats-service/clients) in `$HOME`. Then run the following command (from Perlmutter) to test:

```bash
./nats rtt -s nats://nats-external.nats-helm-test.production.svc.spin.nersc.org:5672
# > nats://128.55.212.94:5672: 223.745µs
```

### Connections outside of NERSC Network

You have to use a websocket connection for external connections. We will let the nats helm chart manage an ingress, and install a TLS certificate using [../tls-acme/](../tls-acme/).

Uncomment the lines in `values.yaml` under `websocket:`, then add any IPs that will be accessing this NATS cluster using `nginx.ingress.kubernetes.io/whitelist-source-range`. You can completely remove everything under `merge` to allow all IP addresses, but note that anyone will be able to send messages to your NATS cluster. The default settings will only allow NERSC/Spin traffic.

Upgrade the nats helm chart (use above command, again). Then, install the tls-acme chart using the values in [`tls-acme-values.yaml`](./tls-acme-values.yaml) in this repo

```bash
cd spin-helm/tls-acme
helm upgrade --install -n <your-namespace> -f ../nats/tls-acme-values.yaml acmecron .
```

Once this has been installed on your namespace, follow instructions in [../tls-acme/README.md](../tls-acme/README.md) to run the first cronjob.

Once you are done with this, run the following to test:

```bash
nats rtt -s wss://ingress.<your-namespace>.production.svc.spin.nersc.org:443
# > wss://ingress.nats-helm-test.production.svc.spin.nersc.org:443:
#
#    wss://128.55.206.106:443: 117.509625ms
#    wss://128.55.206.108:443: 114.822025ms
#    wss://128.55.206.111:443: 121.742425ms
#    wss://128.55.206.107:443: 109.593566ms
#    wss://128.55.206.113:443: 121.545141ms
#    wss://128.55.206.112:443: 125.978374ms
#    wss://128.55.206.109:443: 118.788233ms
#    wss://128.55.206.110:443: 117.792016ms
```

**NOTE:** Again, you must set `nginx.ingress.kubernetes.io/whitelist-source-range` to include your IP address, or remove it entirely if you are testing this from your computer.
