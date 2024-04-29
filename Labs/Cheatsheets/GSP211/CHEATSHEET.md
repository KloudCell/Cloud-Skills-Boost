# **To be done using Google Cloud Shell**

**1. Create the managementnet network**

**2. Create the privatenet network**

**3. Create the firewall rules for managementnet**

**4. Create the firewall rules for privatenet**

**5. Create the managementnet-vm instance**

**6. Create the privatenet-vm instance**

**7. Create a VM instance with multiple network interfaces**

```bash
ZONE=$(gcloud compute instances list --filter="name=mynet-us-vm" --format "get(zone)" | awk -F/ '{print $NF}')
REGION=${ZONE::-2}

ZONE_2=$(gcloud compute instances list --filter="name=mynet-eu-vm" --format "get(zone)" | awk -F/ '{print $NF}')
REGION_2=${ZONE_2::-2}

gcloud compute networks create managementnet \
--subnet-mode=custom

gcloud compute networks subnets create managementsubnet-$REGION \
--network=managementnet \
--region=$REGION \
--range=10.130.0.0/20

gcloud compute networks create privatenet \
--subnet-mode=custom

gcloud compute networks subnets create privatesubnet-$REGION \
--network=privatenet \
--region=$REGION \
--range=172.16.0.0/24

gcloud compute networks subnets create privatesubnet-$REGION_2 \
--network=privatenet \
--region=$REGION_2 \
--range=172.20.0.0/20

gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp \
--direction=INGRESS \
--priority=1000 \
--network=managementnet \
--action=ALLOW \
--rules=tcp:22,tcp:3389,icmp \
--source-ranges=0.0.0.0/0


gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp \
--direction=INGRESS \
--priority=1000 \
--network=privatenet \
--action=ALLOW \
--rules=icmp,tcp:22,tcp:3389 \
--source-ranges=0.0.0.0/0

gcloud compute instances create managementnet-$REGION-vm \
--zone=$ZONE \
--machine-type=e2-micro \
--subnet=managementsubnet-$REGION

gcloud compute instances create privatenet-$REGION-vm \
--zone="$ZONE" \
--machine-type=e2-micro \
--subnet=privatesubnet-$REGION


gcloud compute instances create vm-appliance \
--zone=$ZONE \
--machine-type=e2-standard-4 \
--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=managementsubnet-$REGION \
--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=privatesubnet-$REGION \
--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=mynetwork
```
## Lab Completed🎉