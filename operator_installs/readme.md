*INSTALL LOGGING OPERATORS*
-----------------------------------------


**Prep Operator NS**
./operator_installs/label-ns.sh 

ONLY If openshift-operators-redhat does NOT have an operator group yet
oc create -f operator_installs/openshift-operators-redhat-opgroup.yaml 


-----------------------------------------
***Install Operators***

Install openshift-logging & loki operator
oc create -f operator_installs/logging-subscription.yaml 
oc create -f operator_installs/loki-subscription.yaml 
