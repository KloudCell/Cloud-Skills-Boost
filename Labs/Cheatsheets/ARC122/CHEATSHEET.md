# **To be execute in Google Cloud Shell**

**1. Create an API key**

**2. Create and Update the json file**

**3. Update the json file to use the LANDMARK_DETECTION method**

```bash
export BUCKET=$(gcloud info --format='value(config.project)')-bucket

export API_KEY=$(gcloud beta services api-keys create --display-name='KloudCell' 2>&1 >/dev/null | grep -o 'keyString":"[^"]*' | cut -d'"' -f3)

acl=$(gsutil acl get gs://$BUCKET/manif-des-sans-papiers.jpg)

if echo "$acl" | grep -q "allUsers"; then
    echo "Your image is publicly available."
else
    gsutil acl -r set public-read gs://$BUCKET
fi

echo '{
    "requests": [
        {
        "image": {
            "source": {
                "gcsImageUri": "gs://BUCKET/manif-des-sans-papiers.jpg"
            }
        },
        "features": [
            {
            "type": "TEXT_DETECTION" ,
            "maxResults": 10
            }
        ]
    }
    ]
}' > request.json

sed -i "s/BUCKET/$BUCKET/g" request.json

curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY} -o text-response.json

gsutil cp text-response.json gs://$BUCKET

sleep 12

echo '{
"requests": [
    {
        "image": {
        "source": {
            "gcsImageUri": "gs://BUCKET/manif-des-sans-papiers.jpg"
        }
        },
        "features": [
        {
            "type": "LANDMARK_DETECTION" ,
            "maxResults": 10
        }
        ]
    }
]
}' > request.json

sed -i "s/BUCKET/$BUCKET/g" request.json

curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json  https://vision.googleapis.com/v1/images:annotate?key=${API_KEY} -o landmark-response.json

gsutil cp landmark-response.json gs://$BUCKET
```

## Lab Completed🎉