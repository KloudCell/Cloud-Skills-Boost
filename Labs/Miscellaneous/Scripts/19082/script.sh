#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

echo -e "\033[33mPaste 'Username 2' here:\033[0m \c"
read USER_2

# Create a bucket and upload a sample file

if (gsutil mb -l us gs://$ID

touch sample.txt

gsutil cp sample.txt gs://$ID)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Bucket Created & File Uploaded: Checkpoint Completed (1/4)'

# Remove project access

    if (gcloud projects remove-iam-policy-binding $ID --member=user:$USER_2 --role=roles/viewer)

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Access Removed: Checkpoint Completed (2/4)'

# Add storage permissions

        if (gcloud projects add-iam-policy-binding $ID \
        --role=roles/storage.objectViewer \
        --member=user:$USER_2)

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Storage Permission Added: Checkpoint Completed (3/4)'

# Set up the Service Account User and create a VM

            if (gcloud iam service-accounts create read-bucket-objects --display-name "read-bucket-objects" 

            gcloud iam service-accounts add-iam-policy-binding  read-bucket-objects@$ID.iam.gserviceaccount.com --member=domain:altostrat.com --role=roles/iam.serviceAccountUser

            gcloud projects add-iam-policy-binding $ID --member=domain:altostrat.com --role=roles/compute.instanceAdmin.v1

            gcloud projects add-iam-policy-binding $ID --member="serviceAccount:read-bucket-objects@$ID.iam.gserviceaccount.com" --role="roles/storage.objectViewer"

            gcloud compute instances create demoiam \
            --zone=$ZONE \
            --machine-type=e2-micro \
            --image-family=debian-11 \
            --image-project=debian-cloud \
            --service-account=read-bucket-objects@$ID.iam.gserviceaccount.com)

            then
                printf "\n\e[1;96m%s\n\n\e[m" 'Service Account Set Up & VM Created : Checkpoint Completed (4/4)'
            fi     
        fi
    fi
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all
