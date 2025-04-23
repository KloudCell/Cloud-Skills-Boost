# **To be done using Google Cloud Shell**

**1. Create an API Key**

**2. Create your Speech API request**

**3. Call the Speech API for English language**

**4. Call the Speech API for French language**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud beta services api-keys create --display-name="KloudCell"
KEY_NAME=$(gcloud services api-keys list --format "value(name)" | head -n 1)
API_KEY=$(gcloud services api-keys get-key-string $KEY_NAME --format "value(keyString)")

cat > var.sh << EOF
export API_KEY=$API_KEY
EOF

cat << 'EOFD' > script.sh
cat > request.json <<EOF
{
  "config": {
      "encoding":"FLAC",
      "languageCode": "en-US"
  },
  "audio": {
      "uri":"gs://cloud-samples-data/speech/brooklyn_bridge.flac"
  }
}
EOF

curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json

while true; do
    echo -n "Press Y/y if you got 'Green Tick' in 'Task 3' otherwise wait until you get 'Green Tick':"
    read -r key
    if [ "$key" = "Y" ] || [ "$key" = "y" ]; then
        break
    fi
done

rm -f request.json
cat > request.json <<EOF
 {
  "config": {
      "encoding":"FLAC",
      "languageCode": "fr"
  },
  "audio": {
      "uri":"gs://cloud-samples-data/speech/corbeau_renard.flac"
  }
}
EOF

curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json
EOFD

gcloud compute scp var.sh script.sh linux-instance:~ --zone $ZONE -q
gcloud compute ssh --zone "$ZONE" "linux-instance" --command " . var.sh && . script.sh" -q
```

## Lab Completed🎉