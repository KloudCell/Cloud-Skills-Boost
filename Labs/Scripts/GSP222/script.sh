#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

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

# Enable the Text-to-Speech API
if (gcloud services enable texttospeech.googleapis.com && sleep 3)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Text-to-Speech API is Enabled: Checkpoint Completed (1/2)'

# Create a service account
    if (gcloud iam service-accounts create tts-qwiklab
    gcloud iam service-accounts keys create tts-qwiklab.json --iam-account tts-qwiklab@$ID.iam.gserviceaccount.com
    sleep 3)

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Service account is created: Checkpoint Completed (2/2)'
    fi
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all