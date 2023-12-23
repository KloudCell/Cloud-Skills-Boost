#! /bin/bash

export ID=$(gcloud info --format='value(config.project)')

export ZONE=$(gcloud compute project-info describe --project $ID --format="value(commonInstanceMetadata.items.google-compute-default-zone)")

export REGION=${ZONE::-2}

export API_KEY=$(gcloud beta services api-keys create --display-name='API key 1' 2>&1 >/dev/null | grep -o 'keyString":"[^"]*' | cut -d'"' -f3)

gcloud config set compute/region $REGION1

BRIGHT_RED='\033[1;31m'
NC='\033[0m' # No Color

echo -e "Your Default PROJECT ID: ${BRIGHT_RED}$ID${NC}"
echo -e "Your Default ZONE      : ${BRIGHT_RED}$ZONE${NC}"
echo -e "Your Default REGION    : ${BRIGHT_RED}$REGION${NC}"
echo -e "Your API KEY           : ${BRIGHT_RED}$API_KEY${NC}"

