*Migrate cluster-logging from eleasticsearch to LokiStack*
-----------------------------------------


**Pre Requisites**
- Lokistack logging-lokistack created
- current cluster logging includes elastic kibana fluentd


-----------------------------------------

**PRESERVING DEPRECATED ELEASTICSEARCH & KIBANA**

[0]
Grab backups of original cluster-logging instance, elastic & kibana (optional)

oc get clusterlogging/instance -n openshift-logging -oyaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)'  > cluster_logging/backups/efk-logging.yaml

oc get elasticsearch elasticsearch -n openshift-logging -o yaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)'  > cluster_logging/backups/elasticsearch-beforemod.yaml

oc get kibana kibana -n openshift-logging -o yaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)' > cluster_logging/backups/beforemod-kibana.yaml

-----------------------------------------

Patch opeerator to unmanaged
oc patch clusterlogging/instance -n openshift-logging --type=merge -p '{"spec":{"managementState":"Unmanaged"}}'

Remove owner reference from elasticsearch & kibana
oc patch elasticsearch/elasticsearch -n openshift-logging  --type=merge -p '{"metadata":{"ownerReferences":[]}}'
oc patch kibana/kibana -n openshift-logging  --type=merge -p '{"metadata":{"ownerReferences":[]}}'

-----------------------------------------
Grab backups of elastic & kibana AFTER owner ref is removed  (optional but recommended)
oc get elasticsearch elasticsearch -n openshift-logging -o yaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)'  > cluster_logging/backups/cr-elasticsearch.yaml
oc get kibana kibana -n openshift-logging -o yaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)' > cluster_logging/backups/cr-kibana.yaml

-----------------------------------------

Delete current cluster-logging instance
oc delete clusterlogging/instance -n openshift-logging

Create new cluster logging instance
oc create -f cluster_logging/migration/lfk-logging.yaml

-----------------------------------------

**LOGGING VIEW PLUGIN**

To view the cluster logs stored in the logging lokistack, the logging-view-plugin must be enabled
oc patch consoles.operator.openshift.io cluster  --type=merge --patch '{ "spec": { "plugins": ["logging-view-plugin"] } }'

Ensure console pods restarted
oc get pods -A | grep console

If not, restart manually:
TODO put command


-----------------------------------------

**RESOURCES**
[0] https://access.redhat.com/articles/6991632
