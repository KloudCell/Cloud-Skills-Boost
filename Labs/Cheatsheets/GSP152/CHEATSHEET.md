# **To be done using Google Cloud Shell**

**Create a Cloud SQL instance**

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh


gcloud sql instances create myinstance \
    --database-version=POSTGRES_15 \
    --tier=db-custom-2-7680 \
    --region=$REGION \
    --storage-type=SSD \
    --storage-size=100GB
```
## Lab Completed🎉