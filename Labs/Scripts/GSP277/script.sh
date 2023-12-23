#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
chmod +x welcome.sh
./welcome.sh

# Initialization
gcloud init --skip-diagnostics

export ID=$(gcloud config list --format 'value(core.project)')

# Create Cloud Storage Bucket
if (gsutil mb gs://$ID-bucket)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Created Bucket: Checkpoint Completed (1/3)'

# Upload an image in a storage bucket (demo-image.jpg)
    if (wget -O demo-image.jpg https://cdn.qwiklabs.com/3hpf8ZMmvpav2QvPqQCY1Zl1O%2B%2F8rrass6yjAPki3Dc%3D
        gsutil cp demo-image.jpg gs://$ID-bucket)
    
    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Uploaded the image to Bucket: Checkpoint Completed (2/3)'

# Make the uploaded image publicly accessible.
        if (gsutil acl ch -u AllUsers:R gs://$ID-bucket/demo-image.jpg)
        
        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Image is now publicly accessible: Checkpoint Completed (3/3)'

        fi
    fi    
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all