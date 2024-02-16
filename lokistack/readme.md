# **CREATE LOKISTACK**
-----------------------------------------

## **Pre Requisites**
- loki operator installed

-----------------------------------------
## **Configure storage backend**
### *GCP: GCS Object Store*

##### Create service account [^0]
```sh
gcloud iam service-accounts create <sa-name> --description="description" --display-name=<sa-name>
```
##### Create bucket [^1]
```sh
gcloud storage buckets create gs://<bucket-name> --uniform-bucket-level-access --location=<region>
```
##### Grant service account storage admin role to bucket [^3] [^4]
```sh
gcloud storage buckets add-iam-policy-binding gs://<bucket-name> --member=serviceAccount:<sa-name>@<project>.iam.gserviceaccount.com --role=roles/storage.objectAdmin 
```
##### Create json key for Loki to auth via service account [^4]
```sh
gcloud iam service-accounts keys create <sa-name>.json --iam-account=<sa-name>@<project>.iam.gserviceaccount.com
```
-----------------------------------------

### *AWS: s3*

Create service account

##### Create service account 
```sh
  aws iam service-accounts create <sa-name> --description="<description>" --display-name=<sa-name>
```

##### Create s3 bucket 
```sh
  aws s3 api create-bucket --bucket <bucket-name> --region us-east-2 --create-bucket-configuration LocationConstraint=<aws-region>
```

##### Grant service account full access to bucket 
```sh
  aws iam put-user-policy --<sa-name> loki-bucket-sa --policy-name s3-full-access-policy --policy-document file://<path>/rosa-loki-bucket-policy.json
```

### To verify policy placement
```sh
  aws iam get-user-policy --user-name <sa-name> --policy-name s3-full-access-policy

```
##### Create access key for Loki to auth via service account 
```sh
  aws iam create-access-key --user-name <sa-name>
```


-----------------------------------------
## **Create LokiStack**

##### Create secret in OCP containing bucketname & referencing json key file 
###### *GCS ONLY. For other storage providers and the secret format required see [^5]*
```sh
oc create secret generic <secret-name> -n openshift-logging  --from-literal=bucketname=<bucket-name> --from-file=key.json=<sa-name>.json 
```
##### Create lokistack [^6]
```sh
oc create -f lokistack/logging-lokistack.yaml
```
##### Wait till everything deploys & lokistack reports ready 
```sh
oc describe lokistack/logging-lokistack -n openshift-logging 
```
-----------------------------------------
TODO:
additional lokistacks: with node selectors, different sizes etc.

-----------------------------------------

## **Resources**

[^0]: https://cloud.google.com/iam/docs/service-accounts-create?hl=en#creating
[^1]: https://cloud.google.com/storage/docs/creating-buckets?hl=en#create_a_new_bucket
[^2]: https://cloud.google.com/storage/docs/discover-object-storage-gcloud?hl=en#create
[^3]: https://cloud.google.com/storage/docs/access-control/using-iam-permissions?hl=en#bucket-add
[^4]: https://cloud.google.com/iam/docs/keys-create-delete?hl=en#creating 
[^5]: https://loki-operator.dev/docs/object_storage.md/#google-cloud-storage
    or https://github.com/grafana/loki/blob/main/operator/docs/lokistack/object_storage.md#google-cloud-storage 
[^6]: https://docs.openshift.com/container-platform/4.12/logging/cluster-logging-loki.html
    or https://docs.openshift.com/container-platform/4.12/logging/cluster-logging-loki.html#logging-loki-deploy_cluster-logging-loki


## WIP

From the access key created, note the SecretAccessKey &  AccessKeyId 

Insert that information & the previously gathered bucketname, endpoint & region when creating the below secret 

apiVersion: v1
kind: Secret
metadata:
  name: logging-loki-s3
  namespace: openshift-logging
stringData:
  access_key_id: AccessKeyId
  access_key_secret: SecretAccessKey
  bucketnames: bucketname
  endpoint: endpoint
  region: region

Attach 
aws iam attach-user-policy --user-name YourServiceAccount --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
