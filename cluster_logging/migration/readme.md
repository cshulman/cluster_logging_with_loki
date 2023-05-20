*Migrate cluster-logging from eleasticsearch to LokiStack*
-----------------------------------------


**Pre Requisites**
- Lokistack logging-lokistack created
- current cluster logging includes elastic kibana fluentd


-----------------------------------------
*OPTIONAL*
**PRESERVING DEPRECATED ELEASTICSEARCH & KIBANA**

***BACKUP ELASTICSEARCH & KIBANA INSTANCES ***
Grab backups of original cluster-logging instance, elastic & kibana (optional) [0]

oc get clusterlogging/instance -n openshift-logging -oyaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)'  > cluster_logging/backups/efk-logging.yaml

oc get elasticsearch elasticsearch -n openshift-logging -o yaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)'  > cluster_logging/backups/elasticsearch-beforemod.yaml

oc get kibana kibana -n openshift-logging -o yaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)' > cluster_logging/backups/beforemod-kibana.yaml

-----------------------------------------
-----------------------------------------
*NO UPDATES OR GUARANTEES OF LOG AVAILABILITY AFTER REMOVAL*
***REMOVE OWNER FROM ELEASTICSEARCH & KIBANA**
Patch operator to unmanaged
oc patch clusterlogging/instance -n openshift-logging --type=merge -p '{"spec":{"managementState":"Unmanaged"}}'


Remove owner reference from elasticsearch & kibana
oc patch elasticsearch/elasticsearch -n openshift-logging  --type=merge -p '{"metadata":{"ownerReferences":[]}}'
oc patch kibana/kibana -n openshift-logging  --type=merge -p '{"metadata":{"ownerReferences":[]}}'

-----------------------------------------

*OPTIONAL (RECOMMENDED)*
***BACKUP DEPRECATED ELEASTICSEARCH & KIBANA INSTANCES***

oc get elasticsearch elasticsearch -n openshift-logging -o yaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)'  > cluster_logging/backups/cr-elasticsearch.yaml
oc get kibana kibana -n openshift-logging -o yaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)' > cluster_logging/backups/cr-kibana.yaml

-----------------------------------------
*oc replace does not produce desired results*
**DELETE cluster-logging INSTANCE**

oc delete clusterlogging/instance -n openshift-logging

**CREATE NEW cluster-logging INSTANCE**

oc create -f cluster_logging/migration/lfk-logging.yaml

-----------------------------------------

**LOGGING VIEW PLUGIN**

To view the cluster logs stored in the logging lokistack, the logging-view-plugin must be enabled
oc patch consoles.operator.openshift.io cluster  --type=merge --patch '{ "spec": { "plugins": ["logging-view-plugin"] } }'

Ensure console pods restarted
oc get pods -n openshift-console| grep console

If not, restart manually:
for foo in `oc get pods -n openshift-console| grep console-| grep -v console-operator| awk '{ print $1 }' | grep -v NAME `; do oc delete pod $foo -n openshift-console & ;done

-----------------------------------------

**RESOURCES**
[0] https://access.redhat.com/articles/6991632
