# **Migrate cluster-logging from eleasticsearch to LokiStack**
-----------------------------------------


## **Pre Requisites**
- Lokistack logging-lokistack created
- current cluster logging includes elastic kibana fluentd


-----------------------------------------

### *OPTIONAL:* **Preserve old logging stack (elasticsearch & kibana)** [^0]
###### _Unsupported Configuration. Resources without an owner may become unavailable at any time._

#### Remove owner from elasticsearch & kibana instances

##### Patch cluster-logging instance to unmanaged
```sh
oc patch clusterlogging/instance -n openshift-logging --type=merge -p '{"spec":{"managementState":"Unmanaged"}}'
```
##### Remove owner reference from elasticsearch & kibana
```sh
oc patch elasticsearch/elasticsearch -n openshift-logging  --type=merge -p '{"metadata":{"ownerReferences":[]}}'

oc patch kibana/kibana -n openshift-logging  --type=merge -p '{"metadata":{"ownerReferences":[]}}'
```
##### *Optional (recommended):* Backup deprecated elasticsearch & kibana instances
```sh
oc get elasticsearch elasticsearch -n openshift-logging -o yaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)'  > backups/cr-elasticsearch.yaml

oc get kibana kibana -n openshift-logging -o yaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)' > backups/cr-kibana.yaml
```

-----------------------------------------

## **Delete cluster-logging instance**
```sh
oc delete clusterlogging/instance -n openshift-logging
```
###### *(oc replace does not produce desired results)*
## **Create new cluster-logging instance**
```sh
oc create -f cluster_logging/migration/lfk-logging.yaml
```

-----------------------------------------

## **Logging view plugin**

##### To view the cluster logs stored in the logging lokistack, the logging-view-plugin must be enabled
```sh
oc patch consoles.operator.openshift.io cluster  --type=merge --patch '{ "spec": { "plugins": ["logging-view-plugin"] } }'
```
##### Ensure console pods restarted
```sh
oc get pods -n openshift-console| grep console
```
##### If not, restart manually
```sh
for foo in `oc get pods -n openshift-console| grep console-| grep -v console-operator| awk '{ print $1 }' | grep -v NAME `; do oc delete pod $foo -n openshift-console & ;done
```
-----------------------------------------

## **Resources**
[^0]: https://access.redhat.com/articles/6991632
