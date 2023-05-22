*TODO*
-----------------------------------------


*** CLEANUP ELASTICSEARCH & KIBANA INSTANCES ***

```sh
oc delete elasticsearch elasticsearch -n openshift-logging
```
```sh
oc delete kibana kibana -n openshift-logging
```
-----------------------------------------
*** DELETE ELASTICSEARCH PVC'S ***

```sh
for foo in `oc get pvc -n openshift-logging| grep elastics| awk '{ print $1 }'| grep -v NAME `; do oc delete pvc $foo & done
```
*** DELETE ELASTICSEARCH OPERATOR ***
```sh
oc delete csv elasticsearch-operator.v5.7.1 -n openshift-operators-redhat
```
```sh
oc delete sub elasticsearch-operator -n openshift-operators-redhat
```

-----------------------------------------
