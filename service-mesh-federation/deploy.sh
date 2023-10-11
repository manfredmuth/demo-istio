#!/bin/bash

set -e

log() {
  echo
  echo "##### $*"
}

# -------- snippets
# CURRENT_CONTEXT=$(oc config current-context)
# log "${CURRENT_CONTEXT}"
# oc config rename-context "${CURRENT_CONTEXT}" green-mesh
# oc config rename-context "$(oc config current-context)" red-mesh     

# -------- Phase 0 ------------
# log "Phase 0 - Prep - Deploying subscriptions" -> kaputt -> mache manuell
# oc config use-context green-mesh
# oc get subscriptions.operators.coreos.com -A -o yaml | oc neat > logs-00-subscriptions-greenmesh-before.yaml
# oc get crds -o name > logs-00-crds-greenmesh-before.yaml
# oc create namespace cert-utils-operator
# oc create namespace openshift-distributed-tracing
# helm upgrade prep-green-mesh . -i --create-namespace --kube-context green-mesh --set phase=prep #--dry-run > logs-00-prep-green.yaml        
# # oc wait --kube-context green-mesh --for condition=Ready -n openshift-operators -l name=istio-operator pod --timeout 300s
# oc get subscriptions.operators.coreos.com -A -o yaml | oc neat > logs-01-subscriptions-greenmesh-after.yaml
# oc get crds -o name > logs-01-crds-greenmesh-after.yaml

# oc config use-context red-mesh
# oc get subscriptions.operators.coreos.com -A -o yaml | oc neat > logs-00-subscriptions-redmesh-before.yaml
# oc get crds -o name > logs-00-crds-redmesh-before.yaml
# helm upgrade prep-red-mesh . -i --create-namespace --kube-context red-mesh --set phase=prep --dry-run > prep-red.yaml        
# # oc wait --kube-context red-mesh --for condition=Ready -n openshift-operators -l name=istio-operator pod --timeout 300s
# oc get subscriptions.operators.coreos.com -A -o yaml | oc neat > logs-01-subscriptions-redmesh-after.yaml
# oc get crds -o name > logs-01-crds-redmesh-after.yaml

# -------- Phase 0.1 ------------
# log "Phase 0.1 - Prep - create namespaces manually"
# oc config use-context red-mesh
# oc new-project red-mesh-system 
# oc new-project gm-redmesh-private

# -------- Phase 1.0 ------------
# log "Phase 1.0 - Instance - Deploying resources and instances for operators"
# oc config use-context green-mesh
# helm upgrade instance-green-mesh . -i --kube-context green-mesh --set phase=instance-green-mesh
# oc wait --for condition=Ready -n green-mesh-system smcp/green-mesh --timeout 300s 

oc config use-context red-mesh
helm upgrade instance-red-mesh . -i --kube-context red-mesh --set phase=instance-red-mesh
# oc wait --for condition=Ready -n red-mesh-system smcp/red-mesh --timeout 300s 

oc config use-context blue-mesh
helm upgrade instance-blue-mesh . -i --kube-context blue-mesh --set phase=instance-blue-mesh
# oc wait --for condition=Ready -n blue-mesh-system smcp/blue-mesh --timeout 300s 

# -------- Phase 1.1 ------------
# log "Phase 1.1 - Certificates - Fetching root certificates in each namespace"
# oc config use-context green-mesh
# oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n green-mesh-system > 11-green-mesh-ca-root-cert.pem

# oc config use-context red-mesh
# oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n red-mesh-system > 11-red-mesh-ca-root-cert.pem

# oc config use-context blue-mesh
# oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n blue-mesh-system > 11-blue-mesh-ca-root-cert.pem

# -------- Phase 1.2 ------------
# log "Phase 1.2 - Certificates - Deploying root certificates in each namespace"
# oc config use-context green-mesh
# oc delete configmap red-mesh-ca-root-cert -n green-mesh-system
# oc create configmap red-mesh-ca-root-cert --from-file=root-cert.pem=11-red-mesh-ca-root-cert.pem -n green-mesh-system

# oc config use-context red-mesh
# oc delete configmap green-mesh-ca-root-cert -n red-mesh-system
# oc create configmap green-mesh-ca-root-cert --from-file=root-cert.pem=11-green-mesh-ca-root-cert.pem -n red-mesh-system
# # oc delete configmap blue-mesh-ca-root-cert -n red-mesh-system
# oc create configmap blue-mesh-ca-root-cert --from-file=root-cert.pem=11-blue-mesh-ca-root-cert.pem -n red-mesh-system

# oc config use-context blue-mesh
# # oc delete configmap red-mesh-ca-root-cert -n blue-mesh-system
# oc create configmap red-mesh-ca-root-cert --from-file=root-cert.pem=11-red-mesh-ca-root-cert.pem -n blue-mesh-system

# -------- Phase 2.0 ------------
log "Phase 2.0 - Addresses - Fetch addresses for service mesh peer"
# // TODO: get external address and set it in values.yaml
# AWS: Hostname is enough
# Azure: use the IP and add an annotation
# https://docs.openshift.com/container-platform/4.13/service_mesh/v2x/ossm-federation.html#exposing-the-federation-ingress-on-amazon-web-services-aws

# oc config use-context green-mesh
# ADRESS_FOR_GREEN_MESH=$(oc -n green-mesh-system get svc ingress-red-mesh -o json | jq ".status.loadBalancer.ingress[0].hostname")
# if [ $ADRESS_FOR_GREEN_MESH = "null" ]; then
#   ADRESS_FOR_GREEN_MESH=$(oc -n green-mesh-system get svc ingress-red-mesh -o json | jq ".status.loadBalancer.ingress[0].ip")
# fi
# sed -i "_greenmeshbackup" "s/\"enterAddressForGreenmesh\"/$ADRESS_FOR_GREEN_MESH/g" values.yaml

# oc config use-context red-mesh
# ADRESS_FOR_RED_MESH=$(oc -n red-mesh-system get svc ingress-green-mesh -o json | jq ".status.loadBalancer.ingress[0].hostname")
# if [ $ADRESS_FOR_RED_MESH = "null" ]; then
#   ADRESS_FOR_RED_MESH=$(oc -n red-mesh-system get svc ingress-green-mesh -o json | jq ".status.loadBalancer.ingress[0].ip")
#   oc -n red-mesh-system annotate service ingress-green-mesh service.beta.kubernetes.io/aws-load-balancer-type=nlb
# fi
# sed -i "_redmeshbackup" "s/\"enterAddressForRedmesh\"/$ADRESS_FOR_RED_MESH/g" values.yaml

# oc config use-context blue-mesh
# ADRESS_FOR_BLUE_MESH=$(oc -n blue-mesh-system get svc ingress-red-mesh -o json | jq ".status.loadBalancer.ingress[0].hostname")
# if [ $ADRESS_FOR_BLUE_MESH = "null" ]; then
#   ADRESS_FOR_BLUE_MESH=$(oc -n blue-mesh-system get svc ingress-red-mesh -o json | jq ".status.loadBalancer.ingress[0].ip")
#   oc -n blue-mesh-system annotate service ingress-red-mesh service.beta.kubernetes.io/aws-load-balancer-type=nlb
# fi
# sed -i "_bluemeshbackup" "s/\"enterAddressForBluemesh\"/$ADRESS_FOR_BLUE_MESH/g" values.yaml

# -------- Phase 2.1 ------------
log "Phase 2.1 - Federation - apply service mesh peer"
# oc config use-context green-mesh
# helm upgrade federation-green-mesh . -i --set phase=federation-green-mesh
# oc wait --for condition=Ready -n green-mesh-system servicemeshpeer/red-mesh --timeout 300s 

oc config use-context red-mesh
helm upgrade federation-red-mesh . -i --set phase=federation-red-mesh
# oc wait --for condition=Ready -n red-mesh-system servicemeshpeer/green-mesh --timeout 300s 

oc config use-context blue-mesh
helm upgrade federation-blue-mesh . -i --set phase=federation-blue-mesh
# oc wait --for condition=Ready -n red-mesh-system servicemeshpeer/green-mesh --timeout 300s 

# -------- Phase 3.0 ------------
# telnet 144.76.119.48 32768

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