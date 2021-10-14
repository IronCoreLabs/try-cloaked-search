# Contents

This is an example deployment of cloaked-search, along with a demo deployment of Elasticsearch. The configurations can be used as
a starting point for a customized, production deployment.

- [cs-deploy.yaml](cs-deploy.yaml): The [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) of the
  Cloaked Search Proxy.
- [cs-svc.yaml](cs-svc.yaml): A [Service](https://kubernetes.io/docs/concepts/services-networking/service/) that clients can use to
  connect to the Cloaked Search Proxy from within the same Kubernetes cluster. For access from external clients, consider setting
  up an [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/).
- [es-deploy.yaml](es-deploy.yaml): An example Deployment of Elasticsearch. Unlike a production deployment, this has only one
  replica.
- [es-svc.yaml](es-svc.yaml): A Service that will be used by the Cloaked Search Proxy to send requests to Elasticsearch.
- [kustomization.yaml](kustomization.yaml): A minimal [Kustomize](https://kubernetes-sigs.github.io/kustomize/) configuration to
  control image tags and configuration used by the other files. If you don't want to use Kustomize, `kubectl kustomize . > csp.yaml`
  from this directory will combine all the YAML configuration into a single `csp.yaml` file.
- [ns.yaml](ns.yaml): Creates a dedicated [Namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
  for use by the CSP.
- [pvc.yaml](pvc.yaml): A [PersistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) used by
  Elasticsearch to store its data. There is no PVC for the CSP, because it's stateless.

# Deploy

Examine the config file in `config/deploy.yml` and make changes if desired. The standalone keys referenced in this file are defined
in `kustomization.yaml`, in the `secretGenerator` stanza.

1. Use `kubectl apply -k .` in this directory to start everything up.

# Store documents

If you're no longer running the Docker example from the parent directory, you can use the `populate_index.sh` script to store data
to this Kubernetes deployment.

1. `kubectl port-forward -n cloaked-search svc/cloaked-search 8675`
1. In another terminal, `./populate_index.sh` from the root directory of this repository.

# Post-deploy setup

After starting this demo instance of elasticsearch, and after storing your first document, you need to tell it not to replicate its
indices, since there's only one ES instance.

1. `kubectl port-forward -n cloaked-search svc/elasticsearch 9200`
1. `curl -X PUT -H "Content-type: application/json" -d '{ "index": { "number_of_replicas": 0 }}' http://localhost:9200/_settings`

If you don't do this, elasticsearch status will change to yellow, which Kubernetes will interpret as "not ready" and take it out of
the service load balancer.

# Querying

Make sure you have a `kubectl port-forward` running, as described above, for port 8675. Then you can query the Kubernetes deployment
using the instructions in the [repo root](../README.md).
