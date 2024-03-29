# **To be done using Google Cloud Console and Shell**

**1. Enable Service Account.**

**2. Create a Cloud Run sink.**

**3. Create a Cloud Pub/Sub event trigger.**

**4. Create a bucket.**

**5. Create a Audit Logs event trigger.**
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

gcloud projects get-iam-policy $ID > /tmp/policy.yaml

echo -e "auditConfigs:\n- auditLogConfigs:\n  - logType: ADMIN_READ\n  - logType: DATA_READ\n  - logType: DATA_WRITE\n  service: storage.googleapis.com\n$(cat /tmp/policy.yaml)" > /tmp/temp_policy.yaml && mv /tmp/temp_policy.yaml /tmp/policy.yaml

gcloud projects set-iam-policy $ID /tmp/policy.yaml

echo "Hello World" > random.txt

gsutil cp random.txt gs://${BUCKET_NAME}/random.txt

gcloud beta eventarc attributes types describe google.cloud.audit.log.v1.written


gcloud beta eventarc triggers create trigger-auditlog \
--destination-run-service=${SERVICE_NAME} \
--matching-criteria="type=google.cloud.audit.log.v1.written" \
--matching-criteria="serviceName=storage.googleapis.com" \
--matching-criteria="methodName=storage.objects.create" \
--service-account=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com

while true; do
    # Describe the trigger
    TRIGGER=$(gcloud eventarc triggers describe trigger-auditlog 2>&1)

    # If the trigger exists, break the loop
    if [ $? -eq 0 ]; then
        echo "Trigger 'trigger-auditlog' exists."
        break
    fi

    # If the trigger doesn't exist, create it
    echo "Trigger 'trigger-auditlog' does not exist. Creating..."
    gcloud beta eventarc triggers create trigger-auditlog \
    --destination-run-service=${SERVICE_NAME} \
    --matching-criteria="type=google.cloud.audit.log.v1.written" \
    --matching-criteria="serviceName=storage.googleapis.com" \
    --matching-criteria="methodName=storage.objects.create" \
    --service-account=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com

    # Wait for a while before the next check
    sleep 10
done

# Loop until the trigger is active
while true; do
    # Run the command and save the output
    OUTPUT=$(gcloud eventarc triggers list)

    # Parse the output for trigger-auditlog
    TRIGGER_INFO=$(echo "$OUTPUT" | awk '/trigger-auditlog/,/LOCATION/')

    # Check if the trigger is active
    if echo "$TRIGGER_INFO" | grep -q "ACTIVE: Yes"; then
        echo "Trigger 'trigger-auditlog' is active now. Uploading files to the Bucket now"
        break
    else
        echo "Trigger 'trigger-auditlog' is not active yet."
    fi

    # Wait for a while before the next check
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