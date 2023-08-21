# demo-istio

## Resources
https://docs.openshift.com/container-platform/4.13/service_mesh/v1x/prepare-to-deploy-applications-ossm.html

Skupper bookinfo example
https://github.com/skupperproject/skupper-example-bookinfo


## Installation of operators
+ Service Mesh
+ Kiali
+ Jaeger

```
oc new-project gm-stormshift
oc new-project gm-servicemeshinterconnect
oc new-project service-mesh
oc create -n service-mesh -f config/servicemeshmemberroll-default.yaml
```

Create a fully working bookinfo deployment in the stormshift namespace according to the official documentation

```
oc apply -n gm-stormshift -f https://raw.githubusercontent.com/Maistra/istio/maistra-2.4/samples/bookinfo/platform/kube/bookinfo.yaml
```

Verify the service mesh installation
```
oc get smmr -n service-mesh -o wide
```

Set the route
```
oc apply -n gm-stormshift -f config/bookinfo-gateway.yaml
export GATEWAY_URL=$(oc -n gm-service-mesh get route istio-ingressgateway -o jsonpath='{.spec.host}')
oc apply -n gm-stormshift -f config/destination-rule-all.yaml
```

Check ```curl http://{$GATEWAY_URL}/productpage ```


namespace public/hetzner  gm-servicemeshinterconnect  == production mesh
      trustdomain: hetzner-public.local
namespace private/ibm:    gm-servicemeshfederation    == partner mesh == red-mesh
      trustdomain: ibm-private.local

kubectl config rename-context gm-servicemeshfederation/c104-e-us-east-containers-cloud-ibm-com:30800/IAM#gmodzele@redhat.com red-mesh       
Context "gm-servicemeshfederation/c104-e-us-east-containers-cloud-ibm-com:30800/IAM#gmodzele@redhat.com" renamed to "red-mesh".



context private mesh 
oc logs -n openshift-operators istio-operator-65ccb59c74-bkn9z -f --tail=5| jq .msg

context public mesh
oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n istio-system > 12-public-mesh-cert.pem

context private mesh
oc create configmap public-ca-root-cert --from-file=root-cert.pem=12-public-mesh-cert.pem -n istio-system
oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n $FED_2_SMCP_NAMESPACE > 13-private-mesh-cert.pem"

context public mesh
oc create configmap private-ca-root-cert --from-file=root-cert.pem=14-private-mesh-cert.pem -n istio-system




check connection working? -> not
oc get servicemeshpeer basic -o jsonpath='{.status.discoveryStatus.active[0].watch.connected}{"\n"}' -n istio-system

TODOs:
- Check for wrong addresses
- aufmalen!!!

public mesh ingress: 
http://public-mesh-ingress-istio-system.rhpds-433dee0b4ccaac7b6341df52e43bcc94-0000.us-east.containers.appdomain.cloud

private mesh ingress: 
http://private-mesh-ingress-istio-system.apps.ocp.ocp-gm.de


secondrun

oc config use-context green-mesh
oc get route -n green-mesh-system
-> ingress-red-mesh... copy&paste to red-mesh-02-servicemeshpeer.yaml
oc get configmap istio-ca-root-cert -o jsonpath='{.data.root-cert\.pem}' -n green-mesh-system > 03-green-mesh-ca-root-cert.pem

-> switch context to red-mesh
oc create configmap green-mesh-ca-root-cert --from-file=root-cert.pem=03-green-mesh-ca-root-cert.pem -n red-mesh-system