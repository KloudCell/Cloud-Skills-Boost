#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

# Create a Compute Engine instance and add Nginx Server to your instance with necessary firewall rules.

if (gcloud compute instances create gcelab \
--project=$ID \
--zone=$ZONE \
--machine-type=e2-medium \
--tags=http-server,https-server \
--image-family=debian-11 \
--image-project=debian-cloud

gcloud compute firewall-rules create allow-http --network=default --allow=tcp:80 --target-tags=allow-http

gcloud compute ssh --zone "$ZONE" "gcelab" --project "$ID" --quiet --command "sudo apt-get update && sudo apt-get install -y nginx && ps auwx | grep nginx")

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Compute Engine Created: Checkpoint Completed (1/2)'

# Create a new instance with gcloud.

    if (gcloud compute instances create gcelab2 --machine-type e2-medium --zone=$ZONE)

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'New Instance Created: Checkpoint Completed (2/2)'
    fi
printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all