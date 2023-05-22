# **Openshift cluster logging with Loki**
-----------------------------------------


## **Pre Requisites**
- cluster-logging & loki operators installed
- logging-lokistack created

-----------------------------------------

## **Create cluster-logging instance**

##### Create cluster-logging instance with lokistack + vector
```sh
oc create -f cluster_logging/vector-loki-logging.yaml
```

##### Create cluster-logging instance with lokistack + fluentd
```sh
oc create -f cluster_logging/fluntd-loki-logging.yaml
```
###### TODO add additional instances etc.
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

## **Resources**
https://docs.openshift.com/container-platform/4.12/logging/cluster-logging-loki.html#logging-loki-deploy_cluster-logging-loki
