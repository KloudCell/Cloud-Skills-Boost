# **To be done using Google Cloud Shell**

**1. Create a Lite Topic**

**2. Create a Lite Subscription**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud services enable pubsublite.googleapis.com

gcloud pubsub lite-topics create my-lite-topic \
  --location=$ZONE \
  --partitions=1 \
  --per-partition-bytes=30GiB

gcloud pubsub lite-subscriptions create my-lite-subscription \
  --location=$ZONE \
  --topic=my-lite-topic \
  --delivery-requirement=deliver-after-stored
```

## Lab Completed🎉