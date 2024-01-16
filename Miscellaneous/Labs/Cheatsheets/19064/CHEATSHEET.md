# **To be done using Google Cloud Console and Shell**

**1. Deploy a web server VM instance**

**2. Create a Cloud Storage bucket using the gcloud storage command line**

**3. Create the Cloud SQL instance**

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

gcloud compute instances create bloghost \
    --zone=$ZONE \
    --metadata=startup-script=apt-get\ update$'\n'apt-get\ install\ apache2\ php\ php-mysql\ -y$'\n'service\ apache2\ restart,enable-oslogin=true \
    --tags http-server 

VM_IP=$(gcloud compute instances describe bloghost --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')/32
export LOCATION=US
gcloud storage buckets create -l $LOCATION gs://$ID
gcloud storage cp gs://cloud-training/gcpfci/my-excellent-blog.png my-excellent-blog.png
gcloud storage cp my-excellent-blog.png gs://$ID/my-excellent-blog.png
gsutil acl ch -u allUsers:R gs://$ID/my-excellent-blog.png

gcloud sql instances create blog-db --database-version=MYSQL_8_0 --cpu=2 --memory=8GiB --zone=$ZONE --root-password=password123
gcloud sql users create blogdbuser --instance=blog-db --password=password123
gcloud sql instances patch blog-db --authorized-networks=$VM_IP -q
```

## Lab Completed🎉