# **To be done using Google Cloud Shell**

**1. Create a bucket and upload a sample file**

**2. Remove project access**

**3. Add storage permissions**

**4. Set up the Service Account User and create a VM**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

gsutil mb -l us gs://$ID

touch sample.txt

gsutil cp sample.txt gs://$ID

USER_NAME_2=$(gcloud projects get-iam-policy $ID --format="json" | jq -r --arg USER_NAME "$USER_NAME" '.bindings[] | select(.role == "roles/viewer") | .members[] | select(startswith("user:")) | select(. != "user:" + $USER_NAME) | sub("user:"; "")')

gcloud projects remove-iam-policy-binding $ID --member=user:$USER_NAME_2 --role=roles/viewer

gcloud projects add-iam-policy-binding $ID \
  --role=roles/storage.objectViewer \
  --member=user:$USER_NAME_2

gcloud iam service-accounts create read-bucket-objects --display-name "read-bucket-objects" 

gcloud iam service-accounts add-iam-policy-binding  read-bucket-objects@$ID.iam.gserviceaccount.com --member=domain:altostrat.com --role=roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding $ID --member=domain:altostrat.com --role=roles/compute.instanceAdmin.v1

gcloud projects add-iam-policy-binding $ID --member="serviceAccount:read-bucket-objects@$ID.iam.gserviceaccount.com" --role="roles/storage.objectViewer"

gcloud compute instances create demoiam \
  --zone=$ZONE \
  --machine-type=e2-micro \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --service-account=read-bucket-objects@$ID.iam.gserviceaccount.com
```

## Lab Completed🎉