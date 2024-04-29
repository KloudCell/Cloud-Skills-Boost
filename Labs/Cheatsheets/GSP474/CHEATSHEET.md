# **To be done using Google Cloud Shell**

**1. Build GCP networking footprint**

**2. Create Cloud Firewall Rules and CloudNAT**

**3. Create a CloudRouter and Configure a CloudNAT**

**4. Create Virtual Machines**

**5. Create Internal LoadBalancer**

**6. Configure Packet Mirror Policy**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud compute networks create dm-stamford \
--subnet-mode=custom

gcloud compute networks subnets create dm-stamford-$REGION \
--range=172.21.0.0/24 \
--network=dm-stamford \
--region=$REGION

gcloud compute networks subnets create dm-stamford-$REGION-ids \
--range=172.21.1.0/24 \
--network=dm-stamford \
--region=$REGION

gcloud compute firewall-rules create fw-dm-stamford-allow-any-web \
--direction=INGRESS \
--priority=1000 \
--network=dm-stamford \
--action=ALLOW \
--rules=tcp:80,icmp \
--source-ranges=0.0.0.0/0

gcloud compute firewall-rules create fw-dm-stamford-ids-any-any \
--direction=INGRESS \
--priority=1000 \
--network=dm-stamford \
--action=ALLOW \
--rules=all \
--source-ranges=0.0.0.0/0 \
--target-tags=ids

gcloud compute firewall-rules create fw-dm-stamford-iapproxy \
--direction=INGRESS \
--priority=1000 \
--network=dm-stamford \
--action=ALLOW \
--rules=tcp:22,icmp \
--source-ranges=35.235.240.0/20

gcloud compute routers create router-stamford-nat-$REGION \
--region=$REGION \
--network=dm-stamford

gcloud compute routers nats create nat-gw-dm-stamford-$REGION \
--router=router-stamford-nat-$REGION \
--router-region=$REGION \
--auto-allocate-nat-external-ips \
--nat-all-subnet-ip-ranges

gcloud compute instance-templates create template-dm-stamford-web-$REGION \
--region=$REGION \
--network=dm-stamford \
--subnet=dm-stamford-$REGION \
--machine-type=e2-small \
--image=ubuntu-1604-xenial-v20200807 \
--image-project=ubuntu-os-cloud \
--tags=webserver \
--metadata=startup-script='#! /bin/bash
  apt-get update
  apt-get install apache2 -y
  vm_hostname="$(curl -H "Metadata-Flavor:Google" \
  http://169.254.169.254/computeMetadata/v1/instance/name)"
  echo "Page served from: $vm_hostname" | \
  tee /var/www/html/index.html
  systemctl restart apache2'

gcloud compute instance-groups managed create mig-dm-stamford-web-$REGION \
    --template=template-dm-stamford-web-$REGION \
    --size=2 \
    --zone=$ZONE

gcloud compute instance-templates create template-dm-stamford-ids-$REGION \
--region=$REGION \
--network=dm-stamford \
--no-address \
--subnet=dm-stamford-$REGION-ids \
--image=ubuntu-1604-xenial-v20200807 \
--image-project=ubuntu-os-cloud \
--tags=ids,webserver \
--metadata=startup-script='#! /bin/bash
  apt-get update
  apt-get install apache2 -y
  vm_hostname="$(curl -H "Metadata-Flavor:Google" \
  http://169.254.169.254/computeMetadata/v1/instance/name)"
  echo "Page served from: $vm_hostname" | \
  tee /var/www/html/index.html
  systemctl restart apache2'

gcloud compute instance-groups managed create mig-dm-stamford-ids-$REGION \
    --template=template-dm-stamford-ids-$REGION \
    --size=1 \
    --zone=$ZONE

gcloud compute health-checks create tcp hc-tcp-80 --port 80

gcloud compute backend-services create be-dm-stamford-suricata-$REGION \
--load-balancing-scheme=INTERNAL \
--health-checks=hc-tcp-80 \
--network=dm-stamford \
--protocol=TCP \
--region=$REGION

gcloud compute backend-services add-backend be-dm-stamford-suricata-$REGION \
--instance-group=mig-dm-stamford-ids-$REGION \
--instance-group-zone=$ZONE \
--region=$REGION

gcloud compute forwarding-rules create ilb-dm-stamford-suricata-ilb-$REGION \
 --load-balancing-scheme=INTERNAL \
 --backend-service be-dm-stamford-suricata-$REGION \
 --is-mirroring-collector \
 --network=dm-stamford \
 --region=$REGION \
 --subnet=dm-stamford-$REGION-ids \
 --ip-protocol=TCP \
 --ports=all

gcloud compute packet-mirrorings create mirror-dm-stamford-web \
--collector-ilb=ilb-dm-stamford-suricata-ilb-$REGION \
--network=dm-stamford \
--mirrored-subnets=dm-stamford-$REGION \
--region=$REGION
```
## Lab Completed🎉