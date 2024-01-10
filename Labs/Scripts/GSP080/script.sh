#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud config set compute/region $REGION
mkdir gcf_hello_world &&\
cd gcf_hello_world
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Scripts/GSP080/index.js 2> /dev/null

# Create a cloud storage bucket.
if (gsutil mb -p $ID gs://$ID)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Bucket Created: Checkpoint Completed (1/2)'

# Deploy the function.
    if (gcloud functions deploy helloWorld \
    --stage-bucket $ID \
    --trigger-topic hello_world \
    --runtime nodejs20)

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Function Deployed: Checkpoint Completed (2/2)'
    fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all