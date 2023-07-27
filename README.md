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

