#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

# Bucket
gsutil mb gs://$ID

# Images
wget -O donuts.png https://cdn.qwiklabs.com/V4PmEUI7yXdKpytLNRqwV%2ByGHqym%2BfhdktVi8nj4pPs%3D 2> /dev/null
wget -O city.png https://cdn.qwiklabs.com/9nhXkPugaX2KuBtzDMgr24M%2BiaqXaorWzzhFHZ0XzX8%3D 2> /dev/null
wget -O selfie.png https://cdn.qwiklabs.com/5%2FxwpTRxehGuIRhCz3exglbWOzueKIPikyYj0Rx82L0%3D 2> /dev/null

# Create an API Key
export API_KEY=$(gcloud beta services api-keys create --display-name='API key 1' 2>&1 >/dev/null | grep -o 'keyString":"[^"]*' | cut -d'"' -f3)

printf "\n\e[1;96m%s\n\n\e[m" 'API KEY Created: Checkpoint Completed (1/4)'

# Upload an image to your bucket

if (gsutil cp donuts.png gs://$ID &&\

gsutil acl ch -u AllUsers:R gs://$ID/donuts.png)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Image Uploaded: Checkpoint Completed (2/4)'

# Upload an image for Face Detection to your bucket

    if (gsutil cp selfie.png gs://$ID &&\

    gsutil acl ch -u AllUsers:R gs://$ID/selfie.png)

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Face Detection Done: Checkpoint Completed (3/4)'

# Upload an image for Landmark Annotation to your bucket

        if (gsutil cp city.png gs://$ID

        gsutil acl ch -u AllUsers:R gs://$ID/city.png)

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Landmark Annotation Done: Checkpoint Completed (4/4)'
        fi
    fi
printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all