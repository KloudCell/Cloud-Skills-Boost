# **To be done using Google Cloud Shell**

**1. Create a Compute Engine instance, add necessary firewall rules.**

**2. Configure Apache2 Web Server in your instance**

**3. Test your server**

- Get the Linux virtual machine name from [Task 1](https://www.cloudskillsboost.google/focuses/1734?parent=catalog#step5) and set it to `INSTANCE_NAME`

```
INSTANCE_NAME=
```

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud compute instances create $INSTANCE_NAME \
--project=$ID \
--zone=$ZONE \
--machine-type=f1-micro --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
--metadata=startup-script=sudo\ su\ -$'\n'$'\n'apt-get\ update$'\n'apt-get\ install\ apache2\ -y$'\n'$'\n'service\ \
--status-all$'\n',enable-oslogin=true \
--maintenance-policy=MIGRATE \
--provisioning-model=STANDARD \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--tags=http-server,https-server \
--create-disk=auto-delete=yes,boot=yes,device-name=$INSTANCE_NAME,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240312,mode=rw,size=10,type=projects/$ID/zones/$ZONE/diskTypes/pd-balanced \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--labels=goog-ec-src=vm_add-gcloud \
--reservation-affinity=any

IP=$(gcloud compute instances list $INSTANCE_NAME --zones=$ZONE --format='value(EXTERNAL_IP)')

gcloud compute firewall-rules create allow-http \
    --action=ALLOW \
    --direction=INGRESS \
    --target-tags=http-server \
    --source-ranges=0.0.0.0/0 \
    --rules=tcp:80

sleep 20

curl http://$IP
```
## Lab Completed🎉