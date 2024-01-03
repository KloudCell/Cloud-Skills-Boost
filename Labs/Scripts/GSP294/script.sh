#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

# Create a bucket with the Cloud Storage JSON/REST API
if (BUCKET=$ID-bucket
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Scripts/GSP294/values.json 2> /dev/null

sed -i "s/BUCKET/$BUCKET/g" values.json

curl -H "X-Goog-User-Project: $ID" -H "Authorization: Bearer $(gcloud auth print-access-token)" https://www.googleapis.com/auth/devstorage.full_control
export OAUTH2_TOKEN=$(gcloud auth print-access-token)

curl -X POST --data-binary @values.json \
    -H "Authorization: Bearer $OAUTH2_TOKEN" \
    -H "Content-Type: application/json" \
    "https://www.googleapis.com/storage/v1/b?project=$ID")

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Bucket Created: Checkpoint Completed (1/2)'

# Upload a file using the Cloud Storage JSON/REST API
    if (wget -O demo-image.png https://cdn.qwiklabs.com/PviQ6obeDGvaMjZ7ZRe2VOAArIKl%2B%2FNrBAttlgILNnY%3D 2> /dev/null

    export OBJECT=$PWD/demo-image.png

    curl -X POST --data-binary @$OBJECT \
        -H "Authorization: Bearer $OAUTH2_TOKEN" \
        -H "Content-Type: image/png" \
        "https://www.googleapis.com/upload/storage/v1/b/$BUCKET/o?uploadType=media&name=demo-image")

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'File Uploaded: Checkpoint Completed (2/2)'
    fi
printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all