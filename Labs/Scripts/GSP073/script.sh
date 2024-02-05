#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

export ID=$(gcloud info --format='value(config.project)')

wget -O kitten.png https://cdn.qwiklabs.com/8tnHNHkj30vDqnzokQ%2FcKrxmOLoxgfaswd9nuZkEjd8%3D

# Create a bucket

if (gsutil mb gs://$ID)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Bucket Created: Checkpoint Completed (1/3)'

# Upload an object into the bucket (kitten.png)

    if (gsutil cp kitten.png gs://$ID)

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Image Uploaded: Checkpoint Completed (2/3)'

# Share a kitten.png object publicly

        if (gsutil iam ch allUsers:objectViewer gs://$ID)

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Shared an object publicly: Checkpoint Completed (3/3)'
        fi
    fi
printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all