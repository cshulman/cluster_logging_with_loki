
**** Prerequisite: lokitest-v1 config successful ****



------------------------
logging steps:

#Create logging instance with efk
oc create -f elastic-kibana-fluentd-logging.yaml

oc patch clusterlogging/instance -n openshift-logging --type=merge -p '{"spec":{"managementState":"Unmanaged"}}'

Grab backups of og elastic & kibana
oc -n openshift-logging get elasticsearch elasticsearch -o yaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)'  > elasticsearch-beforemod.yaml
oc -n openshift-logging get kibana kibana -o yaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)' > beforemod-kibana.yaml

Remove owner reference
oc patch elasticsearch/elasticsearch -n openshift-logging  --type=merge -p '{"metadata":{"ownerReferences":[]}}'
oc patch kibana/kibana -n openshift-logging  --type=merge -p '{"metadata":{"ownerReferences":[]}}'

Grab backups of elastic & kibana AFTER owner ref is removed
oc -n openshift-logging get elasticsearch elasticsearch -o yaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)'  > cr-elasticsearch.yaml
oc -n openshift-logging get kibana kibana -o yaml |yq 'del(.metadata.resourceVersion)|del(.metadata.uid)' |yq 'del(.metadata.generation)|del(.metadata.creationTimestamp)' |yq 'del(.metadata.selfLink)|del(.status)' > cr-kibana.yaml



oc delete clusterlogging/instance -n openshift-logging

oc create -f cluster_logging/loki-fluentd-logging.yaml 

---
Enable console plugin & ensure console pods restarted:

oc patch consoles.operator.openshift.io cluster  --type=merge --patch '{ "spec": { "plugins": ["logging-view-plugin"] } }'

oc get pods -A | grep console

