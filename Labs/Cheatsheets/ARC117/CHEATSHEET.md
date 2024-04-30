# **To be done using Google Cloud Shell**

**1. Create a lake with a raw zone in Dataplex**

**2. Create and attach a Cloud Storage bucket to the zone**

**3. Create and apply a tag template**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud services enable \
  dataplex.googleapis.com \
  datacatalog.googleapis.com

gcloud config set compute/region $REGION

gsutil mb -c standard -l $REGION gs://$ID

gcloud dataplex lakes create customer-engagements \
   --location=$REGION \
   --display-name="Customer Engagements" \
   --description="Customer Engagements Domain"

gcloud dataplex zones create raw-event-data \
    --location=$REGION \
    --lake=customer-engagements \
    --display-name="Raw Event Data" \
    --resource-location-type=SINGLE_REGION \
    --type=RAW \
    --discovery-enabled \
    --discovery-schedule="0 * * * *"

gcloud dataplex assets create raw-event-files \
--location=$REGION \
--lake=customer-engagements \
--zone=raw-event-data \
--display-name="Raw Event Files" \
--resource-type=STORAGE_BUCKET \
--resource-name=projects/$ID/buckets/$ID \
--discovery-enabled 

gcloud data-catalog tag-templates create protected_raw_data_flag \
    --location=$REGION \
    --display-name="Protected Raw Data Template" \
    --field=id=protected_raw_data_flag,display-name="Protected Raw Data Flag",type='enum(Y|N)'

ENTRY_NAME=$(gcloud data-catalog entries lookup "//dataplex.googleapis.com/projects/${ID}/locations/${REGION}/lakes/customer-engagements/zones/raw-event-data" --format="value(name)")

cat > tag_file.json << EOF
  {
    "protected_raw_data_flag": "Y"
  }
EOF

gcloud data-catalog tags create --entry=${ENTRY_NAME} \
    --tag-template=protected_raw_data_flag --tag-template-location=$REGION --tag-file=tag_file.json
```
## Lab Completed🎉