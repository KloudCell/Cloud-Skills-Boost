# **To be done using Google Cloud Shell**

**Create a VPC network and VM instance**

- Get `ZONE_1` value for [mynet-us-vm](https://www.cloudskillsboost.google/focuses/41750?parent=catalog#:~:text=mynet-us-vm)

```
ZONE_1=
```
- Get `ZONE_2` value for [mynet-eu-vm](https://www.cloudskillsboost.google/focuses/41750?parent=catalog#:~:text=mynet-eu-vm)
```
ZONE_2=
```
```
gcloud compute networks create mynetwork \
--project=$GOOGLE_CLOUD_PROJECT \
--subnet-mode=auto

gcloud compute firewall-rules create mynetwork-allow-custom --network mynetwork --allow tcp:22,tcp:3389,icmp --project=$GOOGLE_CLOUD_PROJECT

gcloud compute instances create mynet-us-vm \
--project=$GOOGLE_CLOUD_PROJECT \
--zone=$ZONE_1 \
--machine-type=e2-micro \
--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=mynetwork

gcloud compute instances create mynet-eu-vm \
--project=$GOOGLE_CLOUD_PROJECT \
--zone=$ZONE_2 \
--machine-type=e2-micro \
--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=mynetwork
```
## Lab Completed🎉