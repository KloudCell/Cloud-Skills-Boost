# **To be done using Google Cloud Shell**

**Task 1, Task 2, Task 3**

- Check `Form ID`number from [Challenge scenario](https://www.cloudskillsboost.google/focuses/63246?parent=catalog#step4)

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

form_1() {
    gcloud services enable cloudscheduler.googleapis.com

    gcloud pubsub topics create cloud-pubsub-topic

    gcloud pubsub subscriptions create 'cloud-pubsub-subscription' --topic=cloud-pubsub-topic

    gcloud scheduler jobs create pubsub cron-scheduler-job \
            --schedule="* * * * *" --topic=cron-job-pubsub-topic \
            --message-body="Hello World!" --location=$REGION

    gcloud pubsub subscriptions pull cron-job-pubsub-subscription --limit 5
}

form_2() {
    gcloud beta pubsub schemas create city-temp-schema \
        --type=avro \
        --definition='{
            "type": "record",
            "name": "Avro",
            "fields": [
                {
                    "name": "city",
                    "type": "string"
                },
                {
                    "name": "temperature",
                    "type": "double"
                },
                {
                    "name": "pressure",
                    "type": "int"
                },
                {
                    "name": "time_position",
                    "type": "string"
                }
            ]
        }'

    gcloud pubsub topics create temp-topic \
        --message-encoding=JSON \
        --message-storage-policy-allowed-regions=$REGION \
        --schema=projects/$ID/schemas/temperature-schema
    
    git clone https://github.com/GoogleCloudPlatform/nodejs-docs-samples.git

    cd nodejs-docs-samples/functions/v2/helloPubSub/

    fun_2() {
    gcloud functions deploy gcf-pubsub \
    --runtime=nodejs20 \
    --region=$REGION \
    --source=. \
    --entry-point=helloPubSub \
    --trigger-topic=gcf-topic
    }

    while ! fun_2 ; do
    echo "Function Deployment encountered an error will try again after few seconds...";
    sleep 7
    done

}

form_3() {
    gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription

    gcloud pubsub lite-reservations create pubsub-lite-reservation \
        --location=$REGION \
        --throughput-capacity=2

    gcloud services enable cloudscheduler.googleapis.com

    gcloud pubsub lite-topics create cloud-pubsub-topic-lite \
        --location=$REGION \
        --partitions=1 \
        --per-partition-bytes=30GiB \
        --throughput-reservation=demo-reservation

    gcloud pubsub lite-subscriptions create cloud-pubsub-subscription-lite \
            --location=$REGION --topic=cloud-pubsub-topic-lite
}

read -p "Enter your Form number (1, 2, or 3): " form_num

case $form_num in
    1) form_1 ;;
    2) form_2 ;;
    3) form_3 ;;
    *) echo "Invalid form number. Please enter 1, 2, or 3." ;;
esac
```

## Lab Completed🎉