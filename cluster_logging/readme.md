*CLUSTER LOGGING W/ LOKI*
-----------------------------------------


**Pre Requisites**
- cluster-logging & loki operators installed
- logging-lokistack created


***CREATE CLUSTER LOGGING INSTANCE***

Create cluster-logging instance with lokistack + vector
oc create -f cluster_logging/vector-loki-logging.yaml


Create cluster-logging instance with lokistack + fluentd
oc create -f cluster_logging/fluntd-loki-logging.yaml

TODO
add additional instances etc.

-----------------------------------------
**RESOURCES**

https://docs.openshift.com/container-platform/4.12/logging/cluster-logging-loki.html#logging-loki-deploy_cluster-logging-loki
