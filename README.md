# estafette-gke-node-recycler

This small Kubernetes application loops through the hosts in a GKE cluster and recycles them on an interval to prevent hosts from filling up with container images or logs.

[![License](https://img.shields.io/github/license/estafette/estafette-gke-node-recycler.svg)](https://github.com/estafette/estafette-gke-node-recycler/blob/master/LICENSE)


## Why?

With GKE the aggresiveness of cleanup can't be set by the user, so deleting hosts to be replaced by new ones helps keep our cluster in a workable state.

## How does that work

At a given interval, the application gets the list of nodes and check weither the node should be deleted or not. If the annotation doesn't exist, a time to kill value is added to the node annotation with a configurable lifespan, with some randomness added to prevent mass deletion.
When the time to kill time is passed, the Kubernetes node is marked as unschedulable, drained and the instance deleted on GCloud.


## Usage

You can either use environment variables or flags to configure the following settings:

| Environment variable   | Flag                     | Default  | Description
| ---------------------- | ------------------------ | -------- | -----------------------------------------------------------------
| DRAIN_TIMEOUT          | --drain-timeout          | 300      | Max time in second to wait before deleting a node
| INTERVAL               | --interval (-i)          | 600      | Time in second to wait between each node check
| KUBECONFIG             | --kubeconfig             |          | Provide the path to the kube config path, usually located in ~/.kube/config. For out of cluster execution
| METRICS_LISTEN_ADDRESS | --metrics-listen-address | :9001    | The address to listen on for Prometheus metrics requests
| METRICS_PATH           | --metrics-path           | /metrics | The path to listen for Prometheus metrics requests

### Deploy without Helm

```
export NAMESPACE=estafette
export APP_NAME=estafette-gke-node-recycler
export TEAM_NAME=tooling
export VERSION=1.0.35
export GO_PIPELINE_LABEL=1.0.35
export DRAIN_TIMEOUT=300
export INTERVAL=600
export CPU_REQUEST=10m
export MEMORY_REQUEST=16Mi
export CPU_LIMIT=50m
export MEMORY_LIMIT=128Mi

# Setup RBAC
curl https://raw.githubusercontent.com/estafette/estafette-gke-node-recycler/master/rbac.yaml | envsubst | kubectl apply -n ${NAMESPACE} -f -

# Run application
curl https://raw.githubusercontent.com/estafette/estafette-gke-node-recycler/master/kubernetes.yaml | envsubst | kubectl apply -n ${NAMESPACE} -f -
```

### Local development

```
# proxy master
kubectl proxy

# in another shell
go build && ./estafette-gke-node-recycler -i 10
```

Note: `KUBECONFIG=~/.kube/config` as environment variable can also be used if you don't want to use the `kubectl proxy`
command.
