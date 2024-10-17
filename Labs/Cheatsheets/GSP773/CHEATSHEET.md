# **To be done using Google Cloud Shell**

**1. Enable Service Account.**

**2. Create a Cloud Run sink.**

**3. Create a Cloud Pub/Sub event trigger.**

**4. Create a bucket.**

**5. Create a Audit Logs event trigger.**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud config set project $ID
gcloud config set run/region $REGION
gcloud config set run/platform managed
gcloud config set eventarc/location $REGION

gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
  --member=serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com \
  --role='roles/eventarc.admin'

export SERVICE_NAME=event-display
export IMAGE_NAME="gcr.io/cloudrun/hello"

gcloud run deploy ${SERVICE_NAME} \
  --image ${IMAGE_NAME} \
  --allow-unauthenticated \
  --max-instances=3

gcloud eventarc triggers create trigger-pubsub \
  --destination-run-service=${SERVICE_NAME} \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished"

export TOPIC_ID=$(gcloud eventarc triggers describe trigger-pubsub \
  --format='value(transport.pubsub.topic)')

gcloud pubsub topics publish ${TOPIC_ID} --message="Hello there"

export BUCKET_NAME=${ID}-cr-bucket

gsutil mb -p ${ID} \
  -l $(gcloud config get-value run/region) \
  gs://${BUCKET_NAME}/

gcloud projects get-iam-policy $ID > /tmp/policy.yaml

echo -e "auditConfigs:\n- auditLogConfigs:\n  - logType: ADMIN_READ\n  - logType: DATA_READ\n  - logType: DATA_WRITE\n  service: storage.googleapis.com\n$(cat /tmp/policy.yaml)" > /tmp/temp_policy.yaml && mv /tmp/temp_policy.yaml /tmp/policy.yaml

gcloud projects set-iam-policy $ID /tmp/policy.yaml

echo "Hello World" > random.txt

gsutil cp random.txt gs://${BUCKET_NAME}/random.txt

gcloud eventarc triggers create trigger-auditlog \
  --destination-run-service=${SERVICE_NAME} \
  --event-filters="type=google.cloud.audit.log.v1.written" \
  --event-filters="serviceName=storage.googleapis.com" \
  --event-filters="methodName=storage.objects.create" \
  --service-account=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com

while true; do
    TRIGGER=$(gcloud eventarc triggers describe trigger-auditlog 2>&1)

    if [ $? -eq 0 ]; then
        echo "Trigger 'trigger-auditlog' exists."
        break
    fi

    echo "Trigger 'trigger-auditlog' does not exist. Creating..."
    gcloud eventarc triggers create trigger-auditlog \
      --destination-run-service=${SERVICE_NAME} \
      --event-filters="type=google.cloud.audit.log.v1.written" \
      --event-filters="serviceName=storage.googleapis.com" \
      --event-filters="methodName=storage.objects.create" \
      --service-account=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com
    sleep 10
done

while true; do
    OUTPUT=$(gcloud eventarc triggers list)
    TRIGGER_INFO=$(echo "$OUTPUT" | awk '/trigger-auditlog/,/LOCATION/')

    if echo "$TRIGGER_INFO" | grep -q "ACTIVE: Yes"; then
        echo "Trigger 'trigger-auditlog' is active now. Uploading files to the Bucket now"
        break
    else
        echo "Trigger 'trigger-auditlog' is not active yet."
    fi
    sleep 101
done

gsutil cp random.txt gs://${BUCKET_NAME}/random.txt

cat <<'EOF'> ani.sh
echo -e "\033[38;5;208mUploading...\033[0m\033[?25l"

chars="/-\|"

end=$((SECONDS+12))
symbol_end=$((SECONDS+12))

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