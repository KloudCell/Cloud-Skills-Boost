# **To be done using Google Cloud Shell**

**1. Create an API Key**

**2. Create your Speech API request**

**3. Call the Speech API**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud alpha services api-keys create --display-name="kloudcell" 
KEY_NAME=$(gcloud alpha services api-keys list --format="value(name)" --filter "displayName=kloudcell")
API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_NAME --format="value(keyString)")

cat << 'EOF' > script.sh
cat << 'EOFD' > request.json
{
    "config": {
        "encoding":"FLAC",
        "languageCode": "en-US"
    },
    "audio": {
        "uri":"gs://cloud-samples-tests/speech/brooklyn.flac"
    }
  }
EOFD

curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json
EOF

sed -i "s/\${API_KEY}/${API_KEY}/g" script.sh

gcloud compute scp script.sh linux-instance:~/ --zone "$ZONE" --project "$ID" -q
gcloud compute ssh linux-instance --zone "$ZONE" --project "$ID" --quiet --command "bash ~/script.sh"
```

## Lab Completed🎉