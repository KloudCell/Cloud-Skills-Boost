# **To be done using Google Cloud Shell**

**1. Create a Pub/Sub Topic**

**2. Create a Cloud Run sink**

**3. Create a Pub/Sub event trigger**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud services enable \
run.googleapis.com \
eventarc.googleapis.com

gcloud pubsub topics create $ID-topic

gcloud  pubsub subscriptions create --topic $ID-topic $ID-topic-sub

gcloud run deploy pubsub-events \
  --image=gcr.io/cloudrun/hello \
  --platform=managed \
  --region=$REGION \
  --allow-unauthenticated

gcloud eventarc triggers create pubsub-events-trigger \
  --location=$REGION \
  --destination-run-service=pubsub-events \
  --destination-run-region=$REGION \
  --transport-topic=$ID-topic \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished"

gcloud pubsub topics publish $ID-topic \
  --message="Test message"
```

## Lab Completed🎉