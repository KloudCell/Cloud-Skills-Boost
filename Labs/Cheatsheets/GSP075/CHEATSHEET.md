# **To be done using Google Cloud Console and Shell**

**1. Create an API Key**

**2. Upload image to a bucket**

**3. Analyzing the image's text with the Natural Language API**
```
gcloud beta services api-keys create --display-name="API key 1" 2> output.txt
API_KEY=$(grep -oP '"keyString":"\K[^"]+' output.txt)

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud config set compute/region $REGION

gsutil mb gs://$ID-bucket

curl https://cdn.qwiklabs.com/cBoI5P4dZ6k%2FAr5Mv7eME%2F0fCb4G6nIGB0odCXzpEa4%3D --output sign.jpg

gsutil cp sign.jpg gs://$ID-bucket

gsutil acl ch -u AllUsers:R gs://$ID-bucket/sign.jpg


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

sed -i "s/<PROJECT_ID>/$ID/g" ocr-request.json



curl -s -X POST -H "Content-Type: application/json" --data-binary @ocr-request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY}

curl -s -X POST -H "Content-Type: application/json" --data-binary @ocr-request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY} -o ocr-response.json




echo '{
  "q": "your_text_here",
  "target": "en"
}' > translation-request.json

STR=$(jq .responses[0].textAnnotations[0].description ocr-response.json) && STR="${STR//\"}" && sed -i "s|your_text_here|$STR|g" translation-request.json

curl -s -X POST -H "Content-Type: application/json" --data-binary @translation-request.json https://translation.googleapis.com/language/translate/v2?key=${API_KEY} -o translation-response.json

cat translation-response.json




echo '{
  "document":{
    "type":"PLAIN_TEXT",
    "content":"your_text_here"
  },
  "encodingType":"UTF8"
}' > nl-request.json

STR=$(jq .data.translations[0].translatedText  translation-response.json) && STR="${STR//\"}" && sed -i "s|your_text_here|$STR|g" nl-request.json

curl "https://language.googleapis.com/v1/documents:analyzeEntities?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @nl-request.json
```

## Lab Completed🎉