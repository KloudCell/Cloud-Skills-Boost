#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

export BUCKET=$ID-bucket

# Create an API KEY

if [ -n "$API_KEY" ]; then
    sleep 30 && printf "\n\e[1;96m%s\n\n\e[m" 'API KEY Created: Checkpoint Completed (1/3)'
fi

# Get the ACL of the image
acl=$(gsutil acl get gs://$BUCKET/manif-des-sans-papiers.jpg)

# Check if the image is publicly available
if echo "$acl" | grep -q "allUsers"; then
    echo "Your image is publicly available."
else
    # Remove the image from the bucket
    gsutil rm gs://$BUCKET/manif-des-sans-papiers.jpg

    # Download the image
    wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Scripts/ARC122/manif-des-sans-papiers.jpg 2> /dev/null

    # Upload the image to the bucket
    gsutil cp manif-des-sans-papiers.jpg gs://$BUCKET
fi

# Create and Update the json file
wget -O request.json https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Scripts/ARC122/request.json 2> /dev/null

sed -i "s/BUCKET/$BUCKET/g" request.json

curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY} -o text-response.json

gsutil cp text-response.json gs://$BUCKET

if [ $? -eq 0 ]
then
    sleep 30 && printf "\n\e[1;96m%s\n\n\e[m" 'Updated the JSON File to use TEXT_DETECTION method: Checkpoint Completed (2/3)'
fi

# Update the json file to use the LANDMARK_DETECTION method
wget -O request1.json https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Scripts/ARC122/request1.json 2> /dev/null

sed -i "s/BUCKET/$BUCKET/g" request1.json

curl -s -X POST -H "Content-Type: application/json" --data-binary @request1.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY} -o landmark-response.json

gsutil cp landmark-response.json gs://$BUCKET

if [ $? -eq 0 ]
then
    printf "\n\e[1;96m%s\n\n\e[m" 'Updated the JSON File to use LANDMARK_DETECTION method: Checkpoint Completed (3/3)'
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all