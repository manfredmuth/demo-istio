# Demo bookinfo

Simple bookinfo deployment on a cluster.
No magic here yet <-> step by step instructions

## Step1 - deploy bookinfo

```
oc new-project gm-private

oc apply -n gm-private -f gm-private-bookinfo.yaml

```

## Step2 - deploy a virtual machine in the same namespace

Skupper init auf dem private environment ausführen

```skupper init -n gm-private```

> [terminal]$ skupper init -n gm-private 
clusterroles.rbac.authorization.k8s.io "skupper-service-controller" not found
>Skupper is now installed in namespace 'gm-private'.  Use 'skupper status' to get more information.
> [terminal]$ skupper status
Skupper is enabled for namespace "gm-private" in interior mode. It is not connected to any other sites. It has no exposed services.
> [terminal]$ 

```
skupper link create -n gm-private ignore_me/west.token
```

```
skupper expose service details --address details --protocol http
skupper expose service reviews --address reviews --protocol http


## References

[1] [Install virtctl](https://docs.openshift.com/container-platform/4.12/virt/install/virt-installing-virtctl.html)
[2] [Red Virtualization access your machine](https://docs.openshift.com/container-platform/4.11/virt/virtual_machines/virt-accessing-vm-consoles.html)
[3] [Alternative to expose a port in the cluster](https://cloud.redhat.com/blog/accessing-your-vm-using-ssh-and-the-web-console)
