# **To be execute in Google Cloud Shell**

**1. Create a Compute Engine instance and add Nginx Server to your instance with necessary firewall rules.**

**2. Create a new instance with gcloud.**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud compute instances create gcelab \
--project=$ID \
--zone=$ZONE \
--machine-type=e2-medium \
--tags=http-server,https-server \
--image-family=debian-11 \
--image-project=debian-cloud

gcloud compute firewall-rules create allow-http --network=default --allow=tcp:80 --target-tags=allow-http

nginx() {
gcloud compute ssh --zone "$ZONE" "gcelab" --project "$ID" --quiet --command "sudo apt-get update && sudo apt-get install -y nginx && ps auwx | grep nginx"
}

while ! nginx ; do
echo "Instance not ready yet, will try to add NGINX Server again in few seconds..."
sleep 7
done
echo "NGINX Server Added Successfully!"

gcloud compute instances create gcelab2 --machine-type e2-medium --zone=$ZONE
```

## Lab Completed🎉