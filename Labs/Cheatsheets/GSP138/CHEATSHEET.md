# **To be execute in Google Cloud Shell**

**1. Creating Cloud Storage buckets**

**2. Creating Cloud Pub/Sub topics**

**3. Creating Cloud Storage notifications**

**4. Create the BigQuery dataset and table**

**5. Deploying the Cloud Functions**

**6. Testing the flow**

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

export IV_BUCKET_NAME=$ID-upload
export FILTERED_BUCKET_NAME=$ID-filtered
export FLAGGED_BUCKET_NAME=$ID-flagged
export STAGING_BUCKET_NAME=$ID-staging

gsutil mb gs://${IV_BUCKET_NAME}

gsutil mb gs://${FILTERED_BUCKET_NAME}

gsutil mb gs://${FLAGGED_BUCKET_NAME}

gsutil mb gs://${STAGING_BUCKET_NAME}


export UPLOAD_NOTIFICATION_TOPIC=upload_notification
gcloud pubsub topics create ${UPLOAD_NOTIFICATION_TOPIC}


gcloud pubsub topics create visionapiservice

gcloud pubsub topics create videointelligenceservice

gcloud pubsub topics create bqinsert



gsutil notification create -t upload_notification -f json -e OBJECT_FINALIZE gs://${IV_BUCKET_NAME}


gsutil -m cp -r gs://spls/gsp138/cloud-functions-intelligentcontent-nodejs .

cd cloud-functions-intelligentcontent-nodejs

export DATASET_ID=intelligentcontentfilter
export TABLE_NAME=filtered_content

bq --project_id ${ID} mk ${DATASET_ID}

bq --project_id ${ID} mk --schema intelligent_content_bq_schema.json -t ${DATASET_ID}.${TABLE_NAME}

bq --project_id ${ID} show ${DATASET_ID}.${TABLE_NAME}


sed -i "s/\[PROJECT-ID\]/$ID/g" config.json

sed -i "s/\[FLAGGED_BUCKET_NAME\]/$FLAGGED_BUCKET_NAME/g" config.json

sed -i "s/\[FILTERED_BUCKET_NAME\]/$FILTERED_BUCKET_NAME/g" config.json

sed -i "s/\[DATASET_ID\]/$DATASET_ID/g" config.json


sed -i "s/\[TABLE_NAME\]/$TABLE_NAME/g" config.json


gcloud functions deploy GCStoPubsub --runtime nodejs10 --stage-bucket gs://${STAGING_BUCKET_NAME} --trigger-topic ${UPLOAD_NOTIFICATION_TOPIC} --entry-point GCStoPubsub --region $REGION --quiet

gcloud functions deploy visionAPI --runtime nodejs10 --stage-bucket gs://${STAGING_BUCKET_NAME} --trigger-topic visionapiservice --entry-point visionAPI --region $REGION

gcloud functions deploy videoIntelligenceAPI --runtime nodejs10 --stage-bucket gs://${STAGING_BUCKET_NAME} --trigger-topic videointelligenceservice --entry-point videoIntelligenceAPI --timeout 540 --region $REGION --quiet


gcloud functions deploy insertIntoBigQuery --runtime nodejs10 --stage-bucket gs://${STAGING_BUCKET_NAME} --trigger-topic bqinsert --entry-point insertIntoBigQuery --region $REGION --quiet

wget -O demo-image.jpg https://cdn.qwiklabs.com/3hpf8ZMmvpav2QvPqQCY1Zl1O%2B%2F8rrass6yjAPki3Dc%3D

gsutil cp demo-image.jpg gs://$IV_BUCKET_NAME

while [[ $(gcloud beta functions logs read --filter "finished with status" "GCStoPubsub" --limit 100 --region $REGION) != *"finished with status"* ]]; do echo "Waiting for logs for GCStoPubsub..."; sleep 10; done
gcloud beta functions logs read --filter "finished with status" "insertIntoBigQuery" --limit 100 --region $REGION


echo "
#standardSql

SELECT insertTimestamp,
  contentUrl,
  flattenedSafeSearch.flaggedType,
  flattenedSafeSearch.likelihood
FROM \`$ID.$DATASET_ID.$TABLE_NAME\`
CROSS JOIN UNNEST(safeSearch) AS flattenedSafeSearch
ORDER BY insertTimestamp DESC,
  contentUrl,
  flattenedSafeSearch.flaggedType
LIMIT 1000
" > sql.txt

bq --project_id ${ID} query < sql.txt
```

## Lab Completed🎉