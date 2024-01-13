# **To be done using Google Cloud Console and Shell**

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
```
- Run below cmd and use the generated link to navigate to Audit Log

```
echo "https://console.cloud.google.com/iam-admin/audit?project=$ID"
```
- Now, In the list of services, check the box for Google Cloud Storage

- On the right hand side, click the LOG TYPE tab. Admin Write is selected by default, make sure you also select Admin Read, Data Read, Data Write and then click Save.

echo "Hello World" > random.txt

gsutil cp random.txt gs://${BUCKET_NAME}/random.txt

gcloud beta eventarc attributes types describe google.cloud.audit.log.v1.written

count=1

for (( ; ; ))
do
   echo -e "This loop is running for the \033[38;5;48m$count time(s)\033[0m"


   gcloud beta eventarc triggers create trigger-auditlog \
   --destination-run-service=${SERVICE_NAME} \
   --matching-criteria="type=google.cloud.audit.log.v1.written" \
   --matching-criteria="serviceName=storage.googleapis.com" \
   --matching-criteria="methodName=storage.objects.create" \
   --service-account=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com

   sleep 30

   gsutil cp random.txt gs://${BUCKET_NAME}/random.txt

   sleep 120

   echo -e "\033[38;5;208mIf Trigger Testing Completed & you want to exit this loop, then press Ctrl + C\033[0m"

   ((count++))
done

