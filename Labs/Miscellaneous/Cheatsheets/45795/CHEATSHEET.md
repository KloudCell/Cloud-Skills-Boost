# **To be done using Google Cloud Console and Shell**

**1. Create the VM instance**

**2. Create a Cloud Storage bucket and Enable Private Google Access**

**3. Configure a Cloud NAT gateway**

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud compute networks create privatenet \
--project=$ID \
--subnet-mode=custom \
--bgp-routing-mode=regional

gcloud compute networks subnets create privatenet-us \
--project=$ID \
--range=10.130.0.0/20 \
--stack-type=IPV4_ONLY \
--network=privatenet \
--region=$REGION

gcloud compute firewall-rules create privatenet-allow-ssh \
--project=$ID \
--network=privatenet \
--action=ALLOW \
--rules=tcp:22 \
--source-ranges=35.235.240.0/20


gcloud compute instances create vm-internal \
--project=$ID \
--zone=$ZONE \
--machine-type=e2-medium \
--image-family=debian-11 \
--image-project=debian-cloud \
--network-interface=stack-type=IPV4_ONLY,subnet=privatenet-us,no-address

gsutil mb gs://$ID

gcloud storage cp gs://cloud-training/gcpnet/private/access.svg gs://$ID

gcloud compute networks subnets update privatenet-us \
--region=$REGION \
--enable-private-ip-google-access

gcloud compute routers create nat-config \
    --region $REGION \
    --network privatenet 
```

## Lab Completed🎉