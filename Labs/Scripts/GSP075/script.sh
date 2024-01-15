#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

echo '{
  "requests": [
      {
        "image": {
          "source": {
              "gcsImageUri": "gs://<PROJECT_ID>-bucket/sign.jpg"
          }
        },
        "features": [
          {
            "type": "TEXT_DETECTION",
            "maxResults": 10
          }
        ]
      }
  ]
}' > ocr-request.json

echo '{
  "q": "your_text_here",
  "target": "en"
}' > translation-request.json

echo '{
  "document":{
    "type":"PLAIN_TEXT",
    "content":"your_text_here"
  },
  "encodingType":"UTF8"
}' > nl-request.json

gcloud config set compute/region $REGION

gsutil mb gs://$ID-bucket

curl https://cdn.qwiklabs.com/cBoI5P4dZ6k%2FAr5Mv7eME%2F0fCb4G6nIGB0odCXzpEa4%3D --output sign.jpg

# Create an API Key
if (gcloud beta services api-keys create --display-name="API key 1" 2> output.txt)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'API Key Created: Checkpoint Completed (1/3)'

# Upload image to a bucket
    if (gsutil cp sign.jpg gs://$ID-bucket

    gsutil acl ch -u AllUsers:R gs://$ID-bucket/sign.jpg)

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Image Uploaded: Checkpoint Completed (2/3)'

# Analyzing the image's text with the Natural Language API
        if (sed -i "s/<PROJECT_ID>/$ID/g" ocr-request.json

        API_KEY=$(grep -oP '"keyString":"\K[^"]+' output.txt)

        curl -s -X POST -H "Content-Type: application/json" --data-binary @ocr-request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY}

        curl -s -X POST -H "Content-Type: application/json" --data-binary @ocr-request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY} -o ocr-response.json

        STR=$(jq .responses[0].textAnnotations[0].description ocr-response.json) && STR="${STR//\"}" && sed -i "s|your_text_here|$STR|g" translation-request.json

        curl -s -X POST -H "Content-Type: application/json" --data-binary @translation-request.json https://translation.googleapis.com/language/translate/v2?key=${API_KEY} -o translation-response.json

        STR=$(jq .data.translations[0].translatedText  translation-response.json) && STR="${STR//\"}" && sed -i "s|your_text_here|$STR|g" nl-request.json

        curl "https://language.googleapis.com/v1/documents:analyzeEntities?key=${API_KEY}" \
        -s -X POST -H "Content-Type: application/json" --data-binary @nl-request.json)

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Analysis Done: Checkpoint Completed (3/3)'
        fi
    fi
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all