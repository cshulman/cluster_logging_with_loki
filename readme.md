
**** Prerequisite: Scale nodes as needed ****

-----------------------------------------
**Prep Operator NS**

./operator_installs/label-ns.sh 
oc create -f operator_installs/openshift-operators-redhat-opgroup.yaml 
oc create -f operator_installs/logging-subscription.yaml 
oc create -f operator_installs/loki-subscription.yaml 

**Install Operators*

-----------------------------------------

----
Operator installs:
---

./operator_installs/label-ns.sh 
oc create -f operator_installs/openshift-operators-redhat-opgroup.yaml 
oc create -f operator_installs/logging-subscription.yaml 
oc create -f operator_installs/loki-subscription.yaml 

---
Create Lokistack:
---

----
Create clusterLogging instance with lokistack & fluentd*
---

oc create -f cluster_logging/fluntd-loki-logging.yaml
or
oc create -f cluster_logging/vector-loki-logging.yaml

---
Enable console plugin & ensure console pods restarted:
---

oc patch consoles.operator.openshift.io cluster  --type=merge --patch '{ "spec": { "plugins": ["logging-view-plugin"] } }'

oc get pods -A | grep console
