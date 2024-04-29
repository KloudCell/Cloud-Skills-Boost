# **To be done using Google Cloud Shell**

**1. Create a Cloud SQL instance**

**2. Whitelist the Cloud Shell instance to access your SQL instance**

**3. Create a bts database and flights table using the create_table.sql file**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

BUCKET=${ID}-ml

git clone https://github.com/GoogleCloudPlatform/data-science-on-gcp/
cd data-science-on-gcp/03_sqlstudio

gsutil cp create_table.sql gs://$BUCKET/create_table.sql

gcloud sql instances create flights \
--database-version=POSTGRES_13 \
--cpu=2 \
--memory=8GiB \
--region=$REGION \
--root-password=kloudcell

ADDRESS=$(curl -s http://ipecho.net/plain)/32
echo Y | gcloud sql instances patch flights --authorized-networks $ADDRESS

gcloud sql databases create bts --instance=flights

echo Y | gcloud sql import sql flights gs://$BUCKET/create_table.sql --database=bts
```

## Lab Completed🎉