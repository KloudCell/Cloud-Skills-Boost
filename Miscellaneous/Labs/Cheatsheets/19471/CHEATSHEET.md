# **To be done using Google Cloud Shell**

**1. Enable data access logs on Cloud Storage**

**2. Check the creation of bucket, network and virtual machine instance**

**3. Viewing audit logs**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud projects get-iam-policy $ID > /tmp/policy.yaml

echo -e "auditConfigs:\n- auditLogConfigs:\n  - logType: ADMIN_READ\n  - logType: DATA_READ\n  - logType: DATA_WRITE\n  service: storage.googleapis.com\n$(cat /tmp/policy.yaml)" > /tmp/temp_policy.yaml && mv /tmp/temp_policy.yaml /tmp/policy.yaml

gcloud projects set-iam-policy $ID /tmp/policy.yaml

gsutil mb gs://$ID

echo "Hello World!" > sample.txt
gsutil cp sample.txt gs://$ID

gcloud compute networks create mynetwork --subnet-mode=auto

gcloud compute instances create default-us-vm \
--zone=$ZONE --network=mynetwork --machine-type=e2-medium

gcloud logging read \
"logName=projects/$ID/logs/cloudaudit.googleapis.com%2Factivity_log" --project=$ID --format=json

gcloud logging read \
"logName=projects/$ID/logs/cloudaudit.googleapis.com%2Fdata_access" --project=$ID --format=json
```
- `Task 3` need to be done manually if not getting `Green Tick`

## Lab Completed🎉