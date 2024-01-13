# **To be done using Google Cloud Shell**

**1. Create a lake**

**2. Add zone to your lake**

**3. Attach an asset to a zone**

**4. Delete assets, zones, and lakes**

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud config set compute/region $REGION

gsutil mb -l $REGION gs://$ID

gcloud services enable \
  dataplex.googleapis.com 

sleep 12

gcloud dataplex lakes create sensors \
   --location=$REGION \
   --display-name="sensors" \
   --description="credit toh banta hai"


while true; do
  STATE=$(gcloud dataplex lakes describe sensors --location=$REGION --format="get(state)")
  if [ "$STATE" = "ACTIVE" ]; then
    echo "Lake is active. Creating zone now"
    gcloud dataplex zones create temperature-raw-data \
      --location=$REGION \
      --lake=sensors \
      --display-name="temperature raw data" \
      --resource-location-type=SINGLE_REGION \
      --type=RAW \
      --discovery-enabled \
      --discovery-schedule="0 * * * *"
    
    while true; do
      DZONE=$(gcloud dataplex zones describe temperature-raw-data --location=$REGION --lake=sensors  --format="get(state)")
      if [ "$DZONE" = "ACTIVE" ]; then
        echo "Zone is active. Now creating asset."
        gcloud dataplex assets create measurements \
          --location=$REGION \
          --lake=sensors \
          --zone=temperature-raw-data \
          --display-name="measurements" \
          --resource-type=STORAGE_BUCKET \
          --resource-name=projects/$ID/buckets/$ID \
          --discovery-enabled 
        break
      else
        echo "Zone is not active. Checking again in 10 seconds..."
        sleep 10
      fi
    done
    break
  else
    echo "Lake is not active. Checking again in 10 seconds..."
    sleep 10
  fi
done


gcloud dataplex assets delete measurements --location=$REGION --zone=temperature-raw-data --lake=sensors --quiet

gcloud dataplex zones delete temperature-raw-data --location=$REGION --lake=sensors --quiet

gcloud dataplex lakes delete sensors --location=$REGION --quiet
```

## Lab Completed🎉