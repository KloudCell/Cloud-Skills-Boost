#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh


if [ "$REGION" == "us-central1" ]; then
  REGION1=us-central
else
  REGION1=$REGION
fi

git clone https://github.com/GoogleCloudPlatform/golang-samples.git

cd golang-samples/appengine/go11x/helloworld

echo "Y" > a

sudo apt-get install google-cloud-sdk-app-engine-go

gcloud app create --region=$REGION1

# Deploy Go App
if (gcloud app deploy < a)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'App Deployed: Checkpoint Completed (1/1)'
printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all
