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

git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git

cd python-docs-samples/appengine/standard_python3/hello_world

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Scripts/GSP067/main.py 2> /dev/null

echo "Y" > a

gcloud app create --region=$REGION1

# Deploy Python App
if (gcloud app deploy < a)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'App Deployed: Checkpoint Completed (1/1)'
printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all