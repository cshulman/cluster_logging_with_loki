#!/bin/bash

echo -e "\n openshift-logging namespace"
oc label namespace openshift-logging openshift.io/cluster-monitoring=true
#oc patch ns openshift-logging -p '{"metadata":{"annotations":{"openshift.io/node-selector":""}}}'

echo -e "\n openshift-operators-redhat namespace"
oc label namespace openshift-operators-redhat openshift.io/cluster-monitoring=true
#oc patch ns openshift-operators-redhat -p '{"metadata":{"annotations":{"openshift.io/node-selector":""}}}'
echo -e "\n---------------------"


#oc create -f openshift-operators-redhat-opgroup.yaml
#oc create -f logging-subscription.yaml
