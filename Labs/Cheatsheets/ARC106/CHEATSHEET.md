# **To be done using Google Cloud Shell**

**1. Create a Storage bucket**

**2. Create a BQ Dataset and table**

**3. Create a PubSub Topic**

**4. Create a Dataflow Job with the desired configurations**

**5. Publish a test message to the Pub/Sub topic and validate data in Big Query**

- Get these values from below your `Login Credential`

```
export DATASET_NAME=
```
```
export TABLE_NAME=
```
```
export TOPIC_NAME=
```
```
export JOB_NAME=
```

```
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

gcloud dataflow flex-template run $JOB_NAME \
--template-file-gcs-location gs://dataflow-templates-$REGION/latest/flex/PubSub_to_BigQuery_Flex \
--region $REGION --num-workers 2 \
--staging-location gs://$ID/temp \
--parameters \
outputTableSpec=$ID:$DATASET_NAME.$TABLE_NAME,\
inputTopic=projects/$ID/topics/$TOPIC_NAME

gcloud pubsub topics publish $TOPIC_NAME --message='{"data": "73.4 F"}'

cat<<'EOF'>sql.sh
bq query --nouse_legacy_sql 'SELECT * FROM `DATASET.TABLE`'
EOF

sed -i "s/DATASET/$DATASET_NAME/g"  sql.sh
sed -i "s/TABLE/$TABLE_NAME/g"  sql.sh

. sql.sh
```
## Lab Completed🎉