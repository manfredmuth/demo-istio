# Demo bookinfo

Simple bookinfo deployment on a cluster.
No magic here yet <-> step by step instructions

## Step1 - deploy bookinfo

```
oc new-project gm-private

oc apply -n gm-private -f gm-private-bookinfo.yaml

```
