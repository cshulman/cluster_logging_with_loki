# **INSTALL LOGGING OPERATORS**

-----------------------------------------

## **Prep Operator Namespaces**
```sh
./operator_installs/label-ns.sh 
```
#### ONLY If openshift-operators-redhat does NOT have an operator group yet
```sh
oc create -f operator_installs/openshift-operators-redhat-opgroup.yaml 
```

-----------------------------------------

## **Install Operators**

#### Install openshift-logging operator
```sh
oc create -f operator_installs/logging-subscription.yaml 
```

#### Install loki operator

```sh
oc create -f operator_installs/loki-subscription.yaml 
```
