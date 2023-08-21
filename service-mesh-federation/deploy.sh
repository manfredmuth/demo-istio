#!/bin/bash

set -e

log() {
  echo
  echo "##### $*"
}

# kubectl config rename-context blue-mesh-system/api-rosa-vhnkn-ot31-p1-openshiftapps-com:6443/cluster-admin blue-mesh


# -------- Phase 0 ------------
log "Phase 0 - Prep - Deploying subscriptions"
oc config use-context green-mesh
oc get subscriptions.operators.coreos.com -A -o yaml | oc neat > logs-00-subscriptions-greenmesh-before.yaml
oc get crds -o name > logs-00-crds-greenmesh-before.yaml
helm upgrade prep-green-mesh . -i --create-namespace --kube-context green-mesh --set phase=prep --dry-run > prep-green.yaml        
# oc wait --kube-context green-mesh --for condition=Ready -n openshift-operators -l name=istio-operator pod --timeout 300s
oc get subscriptions.operators.coreos.com -A -o yaml | oc neat > logs-01-subscriptions-greenmesh-after.yaml
oc get crds -o name > logs-01-crds-greenmesh-after.yaml

oc config use-context red-mesh
oc get subscriptions.operators.coreos.com -A -o yaml | oc neat > logs-00-subscriptions-redmesh-before.yaml
oc get crds -o name > logs-00-crds-redmesh-before.yaml
helm upgrade prep-red-mesh . -i --create-namespace --kube-context red-mesh --set phase=prep --dry-run > prep-red.yaml        
# oc wait --kube-context red-mesh --for condition=Ready -n openshift-operators -l name=istio-operator pod --timeout 300s
oc get subscriptions.operators.coreos.com -A -o yaml | oc neat > logs-01-subscriptions-redmesh-after.yaml
oc get crds -o name > logs-01-crds-redmesh-after.yaml

# -------- Phase 1 ------------
# log "Phase 1 - Instance - Deploying resources and instances for operators"
# helm upgrade instance-green-mesh . -i --create-namespace --kube-context green-mesh --set phase=instance-green-mesh --dry-run > instance-green.yaml
# oc wait --kube-context green-mesh --for condition=Ready -n green-mesh-system smcp/green-mesh --timeout 300s 
# oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n green-mesh-system > 10-green-mesh-ca-root-cert.pem

# helm upgrade instance-red-mesh . -i --create-namespace --kube-context red-mesh --set phase=instance-red-mesh --dry-run > instance-red.yaml        
# oc wait --kube-context red-mesh --for condition=Ready -n red-mesh-system smcp/red-mesh --timeout 300s 

# "Deploying helm charts"
# helm --upgrade --create-namespace --kube-context red-mesh
# helm --upgrade --create-namespace --kube-context green-mesh

# log "Waiting for prod-mesh installation to complete"
# oc wait --for condition=Ready -n prod-mesh smmr/default --timeout 300s

# oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n green-mesh-system > 03-green-mesh-ca-root-cert.pem

# -> switch context to red-mesh
# oc create configmap green-mesh-ca-root-cert --from-file=root-cert.pem=03-green-mesh-ca-root-cert.pem -n red-mesh-system

# log 'INSTALLATION COMPLETE

# Run the following command in the prod-mesh to check the connection status:

#   oc -n prod-mesh get servicemeshpeer stage-mesh -o json | jq .status

# Run the following command to check the connection status in stage-mesh:

#   oc -n stage-mesh get servicemeshpeer prod-mesh -o json | jq .status

# Check if services from stage-mesh are imported into prod-mesh:

#   oc -n prod-mesh get importedservicesets stage-mesh -o json | jq .status

# Check if services from stage-mesh are exported:

#   oc -n stage-mesh get exportedservicesets prod-mesh -o json | jq .status

# To see federation in action, create some load in the bookinfo app in prod-mesh. For example:

#   BOOKINFO_URL=$(oc -n prod-mesh get route istio-ingressgateway -o json | jq -r .spec.host)
#   while true; do sleep 1; curl http://${BOOKINFO_URL}/productpage &> /dev/null; done

# '