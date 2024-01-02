#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

# Enable the Cloud Natural Language API & Create an API key
if (gcloud services enable \
  language.googleapis.com &&\
  sleep 30)
then
    printf "\n\e[1;96m%s\n\n\e[m" 'CNL API is Enabled & API Key Created: Checkpoint Completed (1/4)'

# Create a request to classify a news article
# Check the Entity Analysis response
    if (wget 2> /dev/null

    sed -i "s/YOUR_API_KEY/$API_KEY/g" a.sh

    gcloud compute ssh linux-instance --zone $ZONE --project "$ID" --quiet --command "bash -s" < a.sh )

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'App Deployed: Checkpoint Completed (2/4)'
        sleep 3.3
        printf "\n\e[1;96m%s\n\n\e[m" 'App Deployed: Checkpoint Completed (3/4)'

# Create a new Dataset and table for categorized text data

        if (bq mk --dataset news_classification_dataset &&\

        bq mk --table news_classification_dataset.article_data article_text:string,category:string,confidence:float)

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Dataset: `news_classification_dataset` and Table: `article_data` Created: Checkpoint Completed (4/4)'
        fi
    fi
printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all

