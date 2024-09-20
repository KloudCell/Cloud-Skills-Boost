# **To be done using Google Cloud Shell**

**1. Create a bucket**

**2. Create a Pub/Sub topic**

**3. Create the Cloud Function**

**4. Remove the previous cloud engineer**

- Set `TOPIC_NAME` to `Pub/Sub Topic Name` from [`Task 2`](https://www.cloudskillsboost.google/focuses/10379?parent=catalog#step6)

```
export TOPIC_NAME=
```

- Set `FUNCTION_NAME` to `Cloud Function Name` from [`Task 3`](https://www.cloudskillsboost.google/focuses/10379?parent=catalog#step7)

```
export FUNCTION_NAME=
```

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

USER_NAME_2=$(gcloud projects get-iam-policy $ID --format="json" | jq -r --arg USER_NAME "$USER_NAME" '.bindings[] | select(.role == "roles/viewer") | .members[] | select(startswith("user:")) | select(. != "user:" + $USER_NAME) | sub("user:"; "")')

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Cheatsheets/GSP315/index.js 2> /dev/null

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Cheatsheets/GSP315/package.json 2> /dev/null

KMS_SERVICE="$(gsutil kms serviceaccount -p $ID)"

BUCKET=gs://$ID-bucket

gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  pubsub.googleapis.com

gcloud projects add-iam-policy-binding $ID \
  --member=serviceAccount:$QWIKLABS_SERVICE \
  --role=roles/pubsub.publisher

gcloud projects add-iam-policy-binding $ID \
  --member=serviceAccount:$SERVICE \
  --role=roles/eventarc.eventReceiver

gcloud projects add-iam-policy-binding $ID \
    --member="serviceAccount:${KMS_SERVICE}" \
    --role='roles/pubsub.publisher'

gsutil mb -c STANDARD -l $REGION -p $ID $BUCKET

gcloud pubsub topics create $TOPIC_NAME

sed -i "8c\functions.cloudEvent('$FUNCTION_NAME', cloudEvent => {" index.js
sed -i "18c\  const topicName = '$TOPIC_NAME';" index.js

deploy_function () {
    gcloud functions deploy $FUNCTION_NAME \
      --gen2 \
      --runtime nodejs20 \
      --entry-point $FUNCTION_NAME \
      --source . \
      --region $REGION \
      --trigger-bucket $BUCKET \
      --trigger-location $REGION \
      --max-instances 1 \
      -q
}
    
SERVICE_NAME="$FUNCTION_NAME"
while true; do
deploy_function

    if gcloud run services describe $SERVICE_NAME --region $REGION &> /dev/null; then
      echo "Cloud Run service created"
      break
    else
      echo "Cloud Run service creating..."
      sleep 12
    fi
done

wget https://storage.googleapis.com/cloud-training/gsp315/map.jpg

gsutil cp map.jpg $BUCKET/

gcloud projects remove-iam-policy-binding $ID \
--member=user:$USER_NAME_2 \
--role=roles/viewer
```

## Lab Completed🎉