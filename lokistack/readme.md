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

##### Create secret in OCP containing bucketname & referencing json key file [^5]
```sh
oc create secret generic <secret-name> -n openshift-logging  --from-literal=bucketname=<bucket-name> --from-file=key.json=<sa-name>.json 
```


-----------------------------------------



### *AWS: s3*

aws sts get-caller-identity
rosa whoami

Create service account

##### Create IAM user/service account 
```sh
  aws iam create-user --user-name <sa-name>
```

##### Create s3 bucket 

###### AWS Region: us-east-1
```sh
  aws s3api create-bucket --bucket <bucket-name> --region us-east-1
```
###### AWS Region: all **except** us-east-1
```sh
  aws s3api create-bucket --bucket <bucket-name> --region <aws-region> --create-bucket-configuration LocationConstraint=<aws-region>
```

##### Create s3 bucket access policy for service account to said bucket
```sh
cat << EOF >> <bucket-name>-access-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "GrantLokiAccessToBucket",
          "Effect": "Allow",
          "Action": [
              "s3:GetObject",
              "s3:PutObject",
              "s3:ListBucket",
              "s3:DeleteObject"
          ],
          "Resource": [
              "arn:aws:s3:::<bucket-name>",
              "arn:aws:s3:::<bucket-name>/*"
          ]
      }
  ]
}
EOF
```

##### Grant IAM account access to bucket 
```sh
  aws iam put-user-policy --user-name <sa-name> --policy-name s3-logloki-access-policy --policy-document file://<path><bucket-name>-access-policy.json

```
  To verify policy placement
  ```sh
    aws iam get-user-policy --user-name <sa-name> --policy-name s3-logloki-access-policy 

  ```
##### Create access key for Loki to auth via service account 
```sh
  aws iam create-access-key --user-name <sa-name>
```

##### Create secret in OCP containing bucket & IAM user information [^5] 

###### Via CLI
```sh
  oc create secret generic -n openshift-logging <sa-name>-aws \       
  --from-literal=bucketnames="<bucket-name>" \
  --from-literal=endpoint="https://s3.<aws-region>.amazonaws.com" \ 
  --from-literal=access_key_id="<access-key-id>" \
  --from-literal=access_key_secret="<secret-access-key>" \
  --from-literal=region="<aws-region>"
```

######  Declaratively
```sh
apiVersion: v1
kind: Secret
metadata:
  name: <sa-name>-aws
  namespace: openshift-logging
stringData:
  access_key_id: <access-key-id>
  access_key_secret: <secret-access-key>
  bucketnames: <bucket-name>
  endpoint: https://s3.<aws-region>.amazonaws.com
  region: <aws-region>
```


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

-----------------------------------------


# WIP

## **Create LokiStack**


##### Create lokistack [^6]
Ensure correct storage type & storageClassName
```sh
oc create -f <path>/logging-lokistack.yaml
```
##### Wait till everything deploys & lokistack reports ready 
```sh
oc describe  <path>/logging-lokistack -n openshift-logging 
```

