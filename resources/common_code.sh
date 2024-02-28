#! /bin/bash

export ID=$(gcloud info --format='value(config.project)')

export ZONE=$(gcloud compute project-info describe --project $ID --format="value(commonInstanceMetadata.items.google-compute-default-zone)")

export SERVICE=$(gcloud compute project-info describe --project $ID --format="value(defaultServiceAccount)")

export REGION=${ZONE::-2}

PROJECT_NUMBER=$(gcloud projects list --filter="project_id:$ID" --format='value(project_number)')

QWIKLABS_SERVICE=$(gcloud iam service-accounts list --filter="displayName:Qwiklabs" --format="value(email)")

#export API_KEY=$(gcloud beta services api-keys create --display-name='API key 1' 2>&1 >/dev/null | grep -o 'keyString":"[^"]*' | cut -d'"' -f3)

BRIGHT_RED='\033[1;31m'
NC='\033[0m' # No Color

echo -e "Your Default PROJECT ID            : ${BRIGHT_RED}$ID${NC}"
echo -e "Your Default ZONE                  : ${BRIGHT_RED}$ZONE${NC}"
echo -e "Your Default REGION                : ${BRIGHT_RED}$REGION${NC}"
echo -e "Your PROJECT NUMBER                : ${BRIGHT_RED}$PROJECT_NUMBER${NC}"
echo -e "Compute Engine Service Account     : ${BRIGHT_RED}$SERVICE${NC}"
echo -e "Qwiklabs User Service Account      : ${BRIGHT_RED}$SERVICE${NC}"
