#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

export LOCATION=US

# Deploy a web server VM instance
if (gcloud compute instances create bloghost \
    --zone=$ZONE \
    --metadata=startup-script=apt-get\ update$'\n'apt-get\ install\ apache2\ php\ php-mysql\ -y$'\n'service\ apache2\ restart,enable-oslogin=true \
    --tags http-server)

then
     printf "\n\e[1;96m%s\n\n\e[m" 'VM Instance Created: Checkpoint Completed (1/3)'

# Create a Cloud Storage bucket using the gcloud storage command line
    if (gcloud storage buckets create -l $LOCATION gs://$ID
    gcloud storage cp gs://cloud-training/gcpfci/my-excellent-blog.png my-excellent-blog.png
    gcloud storage cp my-excellent-blog.png gs://$ID/my-excellent-blog.png
    gsutil acl ch -u allUsers:R gs://$ID/my-excellent-blog.png)

    sleep 7

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Bucket Created: Checkpoint Completed (2/3)'

# Create the Cloud SQL instance
        if (VM_IP=$(gcloud compute instances describe bloghost --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')/32
        gcloud sql instances create blog-db --database-version=MYSQL_8_0 --cpu=2 --memory=8GiB --zone=$ZONE --root-password=password123
        gcloud sql users create blogdbuser --instance=blog-db --password=password123
        gcloud sql instances patch blog-db --authorized-networks=$VM_IP -q)

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'SQL Instance Created: Checkpoint Completed (3/3)'
        fi
    fi
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all