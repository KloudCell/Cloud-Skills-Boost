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

gcloud config set compute/region $REGION1

git clone https://github.com/GoogleCloudPlatform/php-docs-samples.git

cd php-docs-samples/appengine/standard/helloworld

echo "Y" > a

gcloud app create --region=$REGION1

# Deploy a PHP App
if (gcloud app deploy < a)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'App Deployed: Checkpoint Completed (1/1)'
printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all