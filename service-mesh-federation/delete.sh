#!/bin/bash

set -e

log() {
  echo
  echo "##### $*"
}

# kubectl config rename-context blue-mesh-system/api-rosa-vhnkn-ot31-p1-openshiftapps-com:6443/cluster-admin blue-mesh


# -------- Phase 99 delete ------------
log "Phase 00 - delete"
oc config use-context green-mesh
# helm uninstall deployment-green-mesh --kube-context green-mesh --dry-run > deployment-green.yaml        
helm uninstall federation-green-mesh
helm uninstall instance-green-mesh
# helm uninstall prep-green-mesh --kube-context green-mesh --dry-run > prep-green.yaml        

oc config use-context red-mesh
# helm uninstall deployment-red-mesh --kube-context red-mesh --dry-run > deployment-red.yaml        
helm uninstall federation-red-mesh
helm uninstall instance-red-mesh
# helm uninstall prep-red-mesh --kube-context red-mesh --dry-run > prep-red.yaml        

# delete namespaces
# oc delete namespace cert-utils-operator
# oc delete namespace openshift-distributed-tracing
# delete crds