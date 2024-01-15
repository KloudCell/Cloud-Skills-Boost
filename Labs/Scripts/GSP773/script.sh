#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud config set project $ID

gcloud config set run/region $REGION

gcloud config set run/platform managed

gcloud config set eventarc/location $REGION

export PROJECT_NUMBER="$(gcloud projects list \
  --filter=$(gcloud config get-value project) \
  --format='value(PROJECT_NUMBER)')"

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

echo "Hello World" > random.txt

gcloud projects get-iam-policy $ID > /tmp/policy.yaml

echo -e "auditConfigs:\n- auditLogConfigs:\n  - logType: ADMIN_READ\n  - logType: DATA_READ\n  - logType: DATA_WRITE\n  service: storage.googleapis.com\n$(cat /tmp/policy.yaml)" > /tmp/temp_policy.yaml && mv /tmp/temp_policy.yaml /tmp/policy.yaml

gcloud projects set-iam-policy $ID /tmp/policy.yaml

# Enable Service Account.
if (gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
  --member=serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com \
  --role='roles/eventarc.admin')

then
    sleep 7
    printf "\n\e[1;96m%s\n\n\e[m" 'Service Account Enabled: Checkpoint Completed (1/5)'

    export SERVICE_NAME=event-display

    export IMAGE_NAME="gcr.io/cloudrun/hello"

    # Create a Cloud Run sink.
    if (gcloud run deploy ${SERVICE_NAME} \
    --image ${IMAGE_NAME} \
    --allow-unauthenticated \
    --max-instances=3)

    then
        sleep 3
        printf "\n\e[1;96m%s\n\n\e[m" 'Deployed to Cloud Run: Checkpoint Completed (2/5)'

# Create a Cloud Pub/Sub event trigger.
        if (gcloud beta eventarc triggers create trigger-pubsub \
        --destination-run-service=${SERVICE_NAME} \
        --matching-criteria="type=google.cloud.pubsub.topic.v1.messagePublished")

        then
	        sleep 7
            printf "\n\e[1;96m%s\n\n\e[m" 'Deployed to Cloud Run: Checkpoint Completed (3/5)'

            export TOPIC_ID=$(gcloud eventarc triggers describe trigger-pubsub \
            --format='value(transport.pubsub.topic)')

            gcloud pubsub topics publish ${TOPIC_ID} --message="Hello there"

            export BUCKET_NAME=$(gcloud config get-value project)-cr-bucket

# Create a bucket.

            if (gsutil mb -p $(gcloud config get-value project) \
            -l $(gcloud config get-value run/region) \
            gs://${BUCKET_NAME}/)

            then
                printf "\n\e[1;96m%s\n\n\e[m" 'Bucket Created: Checkpoint Completed (4/5)'

                gsutil cp random.txt gs://${BUCKET_NAME}/random.txt

# Create a Audit Logs event trigger.

                if (gcloud beta eventarc triggers create trigger-auditlog \
                --destination-run-service=${SERVICE_NAME} \
                --matching-criteria="type=google.cloud.audit.log.v1.written" \
                --matching-criteria="serviceName=storage.googleapis.com" \
                --matching-criteria="methodName=storage.objects.create" \
                --service-account=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com

                sleep 12

                gsutil cp random.txt gs://${BUCKET_NAME}/random.txt

                source ani.sh)

                then
                    printf "\n\e[1;96m%s\n\n\e[m" 'Trigger Created: Checkpoint Completed (5/5)'
                fi
            fi
        fi
    fi
printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all
