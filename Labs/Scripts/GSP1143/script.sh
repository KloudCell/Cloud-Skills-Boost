#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

while true; do
    # Print the message
    echo -e "Please accept the terms by going to the following link otherwise lab will not complete: \033[0;34mhttps://console.developers.google.com/terms/cloud\033[0m"
    
    # Ask for user input
    read -p "Have you accepted the terms? (y/n) " yn
    
    # Check the user input
    case $yn in
        [Yy]* ) break;;
        * ) echo "Please accept the terms to proceed.";;
    esac
done

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud config set compute/region $REGION

gsutil mb -l $REGION gs://$ID

gcloud services enable \
  dataplex.googleapis.com 

sleep 12

# Create a lake
gcloud dataplex lakes create sensors \
   --location=$REGION \
   --display-name="sensors" \
   --description="credit toh banta hai"


while true; do
  STATE=$(gcloud dataplex lakes describe sensors --location=$REGION --format="get(state)")
  if [ "$STATE" = "ACTIVE" ]; then
    printf "\n\e[1;96m%s\n\n\e[m" 'Lake Created: Checkpoint Completed (1/4)'

    # Add zone to your lake
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
        printf "\n\e[1;96m%s\n\n\e[m" 'Zone Created: Checkpoint Completed (2/4)'

        # Attach an asset to a zone
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

printf "\n\e[1;96m%s\n\n\e[m" 'Asset Created: Checkpoint Completed (3/4)'

# Delete assets, zones, and lakes
if (gcloud dataplex assets delete measurements --location=$REGION --zone=temperature-raw-data --lake=sensors --quiet

gcloud dataplex zones delete temperature-raw-data --location=$REGION --lake=sensors --quiet

gcloud dataplex lakes delete sensors --location=$REGION --quiet)

then
    sleep 12
    printf "\n\e[1;96m%s\n\n\e[m" 'Lake Deleted: Checkpoint Completed (4/4)'
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all