#! /bin/bash

# Initialization
gcloud init --skip-diagnostics

# Create a Compute Engine Virtual Machine Instance
if (gcloud services enable dialogflow.googleapis.com)

then
  printf "\n\e[1;96m%s\n\n\e[m" 'Dialogflow API Enabled (1/1)'
  
  printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all
