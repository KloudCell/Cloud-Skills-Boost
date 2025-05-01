# **To be done using Google Cloud Shell**

**1. Create a virtual machine with gcloud**

**2. Update the firewall**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud compute instances create gcelab2 --machine-type e2-medium --zone $ZONE

gcloud compute instances add-tags gcelab2 --tags http-server,https-server --zone $ZONE

gcloud compute firewall-rules create default-allow-http \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:80 \
--source-ranges=0.0.0.0/0 \
--target-tags=http-server
```

## Lab Completed🎉