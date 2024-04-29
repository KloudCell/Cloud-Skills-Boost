# **To be done using Google Cloud Shell**

**1. Create the cai bucket**

**2. Create the two cai files**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

export CAI_BUCKET_NAME=cai-$ID

gcloud services enable cloudasset.googleapis.com \
    --project $ID

gcloud beta services identity create --service=cloudasset.googleapis.com --project=$ID

gcloud projects add-iam-policy-binding ${ID}  \
   --member=serviceAccount:service-$(gcloud projects list --filter="$ID" --format="value(PROJECT_NUMBER)")@gcp-sa-cloudasset.iam.gserviceaccount.com \
   --role=roles/storage.admin

git clone https://github.com/forseti-security/policy-library.git

cp policy-library/samples/storage_denylist_public.yaml policy-library/policies/constraints/

gsutil mb -l $REGION -p $ID gs://$CAI_BUCKET_NAME

# Export resource data
gcloud asset export \
    --output-path=gs://$CAI_BUCKET_NAME/resource_inventory.json \
    --content-type=resource \
    --project=$ID

# Export IAM data
gcloud asset export \
    --output-path=gs://$CAI_BUCKET_NAME/iam_inventory.json \
    --content-type=iam-policy \
    --project=$ID

# Export org policy data
gcloud asset export \
    --output-path=gs://$CAI_BUCKET_NAME/org_policy_inventory.json \
    --content-type=org-policy \
    --project=$ID

# Export access policy data
gcloud asset export \
    --output-path=gs://$CAI_BUCKET_NAME/access_policy_inventory.json \
    --content-type=access-policy \
    --project=$ID
```
## Lab Completed🎉