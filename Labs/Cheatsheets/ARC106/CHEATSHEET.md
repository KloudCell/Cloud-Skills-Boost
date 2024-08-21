# **To be done using Google Cloud Shell**

**1. Create a Storage bucket**

**2. Create a BQ Dataset and table**

**3. Create a PubSub Topic**

**4. Create a Dataflow Job with the desired configurations**

**5. Publish a test message to the Pub/Sub topic and validate data in Big Query**

- Get these values from below your `Login Credential`

```bash
read -p "Enter BigQuery dataset name:" DATASET_NAME
read -p "Enter BigQuery table name:" TABLE_NAME
read -p "Enter Pub/Sub topic name:" TOPIC_NAME
read -p "Enter Dataflow job name:" JOB_NAME

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

SUB=$TOPIC_NAME-sub

gsutil mb gs://$ID

bq mk $DATASET_NAME

bq mk --table \
$ID:$DATASET_NAME.$TABLE_NAME \
data:string

gcloud pubsub topics create $TOPIC_NAME

gcloud pubsub subscriptions create $SUB --topic=$TOPIC_NAME

gcloud dataflow jobs run $JOB_NAME \
--gcs-location gs://dataflow-templates-$REGION/latest/PubSub_to_BigQuery \
--region $REGION \
--staging-location gs://$ID/temp \
--parameters inputTopic=projects/$ID/topics/$TOPIC_NAME,outputTableSpec=$ID:$DATASET_NAME.$TABLE_NAME

while true; do
    STATE=$(gcloud dataflow jobs list --filter="name=$JOB_NAME" --region $REGION --format="get(state)" | head -n 1)
    if [ "$STATE" == "Pending" ]; then
        echo "Job is in Pending State. Wait till it is running..."
    elif [ "$STATE" == "Failed" ]; then
        echo "Job failed. Retrying..."
        gcloud dataflow jobs run $JOB_NAME \
            --gcs-location gs://dataflow-templates-$REGION/latest/PubSub_to_BigQuery \
            --region $REGION \
            --staging-location gs://$ID/temp \
            --parameters inputTopic=projects/$ID/topics/$TOPIC_NAME,outputTableSpec=$ID:$DATASET_NAME.$TABLE_NAME
    else
        echo "Job completed successfully."
        break
    fi
    sleep 10
done

gcloud pubsub topics publish $TOPIC_NAME --message='{"data": "73.4 F"}'

cat<<'EOF'>sql.sh
bq query --nouse_legacy_sql 'SELECT * FROM `DATASET.TABLE`'
EOF

sed -i "s/DATASET/$DATASET_NAME/g"  sql.sh
sed -i "s/TABLE/$TABLE_NAME/g"  sql.sh

. sql.sh
```

## Lab Completed🎉