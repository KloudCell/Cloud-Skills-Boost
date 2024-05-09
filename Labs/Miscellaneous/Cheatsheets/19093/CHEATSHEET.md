# **To be execute in Google Cloud Shell**

**1. Create a VPC network and VM instances**

**2. Create custom mode VPC networks with firewall rules**

**3. Create VM instances**

- Go to `Task 2` and copy the `ZONE` value of `mynet-eu-vm`
```
export ZONE_2=
```

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

export ZONE_1=$ZONE

gcloud compute networks create mynetwork --project=$ID --subnet-mode=auto

gcloud compute instances create mynet-us-vm \
--project=$ID \
--zone=$ZONE_1 \
--machine-type=e2-micro \
--subnet=mynetwork \
--image-family=debian-11 \
--image-project=debian-cloud

gcloud compute instances create mynet-eu-vm \
--project=$ID \
--zone=$ZONE_2  \
--machine-type=e2-micro \
--subnet=mynetwork \
--image-family=debian-11 \
--image-project=debian-cloud

gcloud compute networks update mynetwork --switch-to-custom-subnet-mode --quiet

gcloud compute networks create managementnet --subnet-mode=custom

gcloud compute networks subnets create managementsubnet-us --network=managementnet --region=${ZONE_1::-2} --range=10.240.0.0/20

gcloud compute networks create privatenet --subnet-mode=custom

gcloud compute networks subnets create privatesubnet-us --network=privatenet --region=${ZONE_1::-2} --range=172.16.0.0/24

gcloud compute networks subnets create privatesubnet-eu --network=privatenet --region=${ZONE_2::-2} --range=172.20.0.0/20

gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp \
--network=managementnet \
--action=ALLOW \
--rules=icmp,tcp:22,tcp:3389 \
--source-ranges=0.0.0.0/0

gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp \
--network=privatenet \
--action=ALLOW \
--rules=icmp,tcp:22,tcp:3389 \
--source-ranges=0.0.0.0/0

gcloud compute instances create managementnet-us-vm \
--zone=$ZONE_1 \
--machine-type=e2-micro \
--subnet=managementsubnet-us \
--image-family=debian-11 \
--image-project=debian-cloud

gcloud compute instances create privatenet-us-vm \
--zone=$ZONE_1 \
--machine-type=e2-micro \
--subnet=privatesubnet-us \
--image-family=debian-11 \
--image-project=debian-cloud
```

## Lab Completed🎉