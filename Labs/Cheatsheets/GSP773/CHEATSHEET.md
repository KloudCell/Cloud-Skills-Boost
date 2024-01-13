# **To be done using Google Cloud Console and Shell**

**1. Enable Service Account.**

**2. Create a Cloud Run sink.**

**3. Create a Cloud Pub/Sub event trigger.**

**4. Create a bucket.**
```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud config set project $ID

gcloud config set run/region $REGION

gcloud config set run/platform managed

gcloud config set eventarc/location $REGION


export PROJECT_NUMBER="$(gcloud projects list \
  --filter=$(gcloud config get-value project) \
  --format='value(PROJECT_NUMBER)')"

gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
  --member=serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com \
  --role='roles/eventarc.admin'

export SERVICE_NAME=event-display

export IMAGE_NAME="gcr.io/cloudrun/hello"

gcloud run deploy ${SERVICE_NAME} \
  --image ${IMAGE_NAME} \
  --allow-unauthenticated \
  --max-instances=3


gcloud beta eventarc attributes types describe \
  google.cloud.pubsub.topic.v1.messagePublished


gcloud beta eventarc triggers create trigger-pubsub \
  --destination-run-service=${SERVICE_NAME} \
  --matching-criteria="type=google.cloud.pubsub.topic.v1.messagePublished"

export TOPIC_ID=$(gcloud eventarc triggers describe trigger-pubsub \
  --format='value(transport.pubsub.topic)')


gcloud pubsub topics publish ${TOPIC_ID} --message="Hello there"

export BUCKET_NAME=$(gcloud config get-value project)-cr-bucket

gsutil mb -p $(gcloud config get-value project) \
  -l $(gcloud config get-value run/region) \
  gs://${BUCKET_NAME}/

echo "https://console.cloud.google.com/iam-admin/audit?project=$ID"
```

- Click on the link generated from the last cmd & navigate to `Audit Log`

- In Filter search `Google Cloud Storage` and check the box next to it.

- Select `Admin Read`, `Data Read`, `Data Write` and Save it.

**5. Create a Audit Logs event trigger.**
```
echo "Hello World" > random.txt

gsutil cp random.txt gs://${BUCKET_NAME}/random.txt

gcloud beta eventarc attributes types describe google.cloud.audit.log.v1.written


gcloud beta eventarc triggers create trigger-auditlog \
--destination-run-service=${SERVICE_NAME} \
--matching-criteria="type=google.cloud.audit.log.v1.written" \
--matching-criteria="serviceName=storage.googleapis.com" \
--matching-criteria="methodName=storage.objects.create" \
--service-account=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com

sleep 12

gsutil cp random.txt gs://${BUCKET_NAME}/random.txt

cat <<'EOF'> ani.sh
echo -e "\033[38;5;208mUploading...\033[0m\033[?25l"

chars="/-\|"

end=$((SECONDS+72))
symbol_end=$((SECONDS+72))

while [ $SECONDS -lt $end ]; do
  for (( i=0; i<${#chars}; i++ )); do
    sleep 0.5
    if [ $SECONDS -lt $symbol_end ]; then
      echo -en "${chars:$i:1}" "\r"
    fi
    if [ $SECONDS -ge $end ]; then
      break
    fi
  done
done

echo -e "\033[2K\033[38;5;82mUploaded\033[0m\033[?25h"
EOF

. ani.sh

```

## Lab Completed🎉