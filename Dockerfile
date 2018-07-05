FROM scratch

LABEL maintainer="estafette.io" \
      description="The estafette-gke-node-recycler component is a Kubernetes controller that loops through GKE cluster nodes and kills a node after a configurable amount of time"

COPY ca-certificates.crt /etc/ssl/certs/
COPY estafette-gke-node-recycler /

CMD ["./estafette-gke-node-recycler"]
