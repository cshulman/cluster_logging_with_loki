# **All things elasticsearch**
-----------------------------------------

##### **TODO**
-----------------------------------------

## Cleanup everything related to elasticsearch & kibana

#### **Delete elasticsearch & kibana instances**

```sh
oc delete elasticsearch elasticsearch -n openshift-logging

oc delete kibana kibana -n openshift-logging
```
-----------------------------------------
#### **Delete elasticsearch PVC'S**

```sh
for foo in `oc get pvc -n openshift-logging| grep elastics| awk '{ print $1 }'| grep -v NAME `; do oc delete pvc $foo & done
```

#### **Delete elasticsearch operator**
```sh
oc delete csv elasticsearch-operator.v5.7.1 -n openshift-operators-redhat

oc delete sub elasticsearch-operator -n openshift-operators-redhat
```
