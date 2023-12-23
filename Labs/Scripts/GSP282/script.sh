#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
chmod +x welcome.sh
./welcome.sh

# Initialization
gcloud init --skip-diagnostics

# Enable Dialogflow API
if (gcloud services enable dialogflow.googleapis.com)

then
  printf "\n\e[1;96m%s\n\n\e[m" 'Dialogflow API Enabled (1/1)'
  
  printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all
