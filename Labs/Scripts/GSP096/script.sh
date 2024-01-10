#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

# Create a Pub/Sub topic.
if (gcloud pubsub topics create MyTopic)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Pub/Sub Topic Created: Checkpoint Completed (1/2)'
 
# Add a subscription. 
    if (gcloud pubsub subscriptions create MySub \
        --topic=MyTopic)
    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Subscription Created: Checkpoint Completed (2/2)'
    fi
printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all