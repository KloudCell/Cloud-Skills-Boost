# **To be done using Google Cloud Shell**

**1. Create a Cloud Storage bucket**

**2. Create and attach a persistent disk to an instance**

**3. Install a NGINX web server**
 
```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gsutil mb -l us gs://$ID-bucket
gcloud storage buckets update gs://$ID-bucket --public-access-prevention
gsutil uniformbucketlevelaccess set on gs://$ID-bucket

gcloud compute instances create my-instance \
    --project=$ID \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --tags=http-server \
    --image-project=debian-cloud \
    --image-family=debian-11 \
    --boot-disk-size=10GB

gcloud compute disks create mydisk \
--size=200GB \
--zone=$ZONE

gcloud compute instances attach-disk my-instance \
--disk mydisk \
--zone=$ZONE

gcloud compute ssh my-instance \
--zone=$ZONE \
--command="sudo apt-get update && sudo apt-get install -y nginx" -q
```

## Lab Completed🎉