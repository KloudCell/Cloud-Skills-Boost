# **To be done using Google Cloud Shell**

**Set up Cloud Pub/Sub**

```bash
gcloud services enable cloudscheduler.googleapis.com

gcloud pubsub topics create cron-topic

gcloud pubsub subscriptions create cron-sub --topic cron-topic

```

## Lab Completed🎉