*CREATE LOKISTACK*
-----------------------------------------

**Pre Requisites**
- loki operator installed


**GCP RESOURCE CREATION**

Links/resources below

gcloud env setup
gcloud init

(to login or check if logged in gcloud auth login, gcloud auth list)

Set default project
gcloud config set project <project>
-----------------------------------------

Create service account [0]
gcloud iam service-accounts create <sa-name> --description="description" --display-name=<sa-name>

Create bucket[1]
gcloud storage buckets create gs://<bucket-name> --uniform-bucket-level-access --location=<region>

Grant service account storage admin role to bucket [3] [4]
gcloud storage buckets add-iam-policy-binding gs://<bucket-name> --member=serviceAccount:<sa-name>@<project>.iam.gserviceaccount.com --role=roles/storage.objectAdmin 

Create json key for Loki to auth via service account[4]
gcloud iam service-accounts keys create <sa-name>.json --iam-account=<sa-name>@<project>.iam.gserviceaccount.com

-----------------------------------------

**LOKISTACK CREATION**
Create secret in OCP containing bucketname & referencing json key file  [5]
oc create secret generic <secret-name> -n openshift-logging  --from-literal=bucketname=<bucket-name> --from-file=key.json=<sa-name>.json 

Create lokistack [6]
oc create -f lokistack/logging-lokistack.yaml

Wait till everything deploys & lokistack reports ready 
oc describe lokistack/logging-lokistack -n openshift-logging 

-----------------------------------------
TODO:
additional lokistacks: with node selectors, different sizes etc.

-----------------------------------------

**RESOURCES**

[0] https://cloud.google.com/iam/docs/service-accounts-create?hl=en#creating
[1] https://cloud.google.com/storage/docs/creating-buckets?hl=en#create_a_new_bucket
[2] https://cloud.google.com/storage/docs/discover-object-storage-gcloud?hl=en#create
[3] https://cloud.google.com/storage/docs/access-control/using-iam-permissions?hl=en#bucket-add
[4] https://cloud.google.com/iam/docs/keys-create-delete?hl=en#creating (Ex: serviceAccount:my-service-account@my-project.iam.gserviceaccount.com)
[5] https://loki-operator.dev/docs/object_storage.md/#google-cloud-storage
    or https://github.com/grafana/loki/blob/main/operator/docs/lokistack/object_storage.md#google-cloud-storage 
[6] https://docs.openshift.com/container-platform/4.12/logging/cluster-logging-loki.html
    or https://docs.openshift.com/container-platform/4.12/logging/cluster-logging-loki.html#logging-loki-deploy_cluster-logging-loki
