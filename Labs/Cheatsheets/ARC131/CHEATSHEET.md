# **To be done using Google Cloud Shell**

**1. Create an API key**

**2. Speech-to-Text transcription in English language**

**3. Speech-to-Text transcription in Spanish language**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

export API_KEY=$(gcloud beta services api-keys create --display-name='KloudCell' 2>&1 >/dev/null | grep -o 'keyString":"[^"]*' | cut -d'"' -f3)

echo -e "\n"
echo -e "\e[1;32m
             > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > >
                          API KEY: \e[1;34mhttps://console.cloud.google.com/apis/credentials?project=$ID/\e[1;32m
             > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > > >\e[0m"
echo -e "\n"
echo "=======================> API KEY: $API_KEY <==========================="
echo -e "\n"
```

- Need to create `API KEY` from console if you didn't get `Green Tick` in `Task 1`
- Use `API KEY` link from terminal to naviagte to console for creating `API KEY`

```bash
read -p "Enter 'request file' name from 'Task 2':" TASK_2_REQUEST_FILE

read -p "Enter 'response file' name from 'Task 2':" TASK_2_RESPONSE_FILE

read -p "Enter 'request file' name from 'Task 3':" TASK_3_REQUEST_FILE

read -p "Enter 'response file' name from 'Task 3':" TASK_3_RESPONSE_FILE

cat << 'EOF' > script.sh
#!/bin/bash

cat > "${TASK_2_REQUEST_FILE}" <<EOJSON
{
  "config": {
    "encoding": "LINEAR16",
    "languageCode": "en-US",
    "audioChannelCount": 2
  },
  "audio": {
    "uri": "gs://spls/arc131/question_en.wav"
  }
}
EOJSON

curl -s -X POST -H "Content-Type: application/json" --data-binary @"${TASK_2_REQUEST_FILE}" \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > "${TASK_2_RESPONSE_FILE}"

cat > "${TASK_3_REQUEST_FILE}" <<EOJSON
{
  "config": {
    "encoding": "FLAC",
    "languageCode": "es-ES"
  },
  "audio": {
    "uri": "gs://spls/arc131/multi_es.flac"
  }
}
EOJSON

curl -s -X POST -H "Content-Type: application/json" --data-binary @"${TASK_3_REQUEST_FILE}" \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > "${TASK_3_RESPONSE_FILE}"
EOF

sed -i "s/\${API_KEY}/${API_KEY}/g" script.sh
sed -i "s/\${TASK_2_REQUEST_FILE}/${TASK_2_REQUEST_FILE}/g" script.sh
sed -i "s/\${TASK_2_RESPONSE_FILE}/${TASK_2_RESPONSE_FILE}/g" script.sh
sed -i "s/\${TASK_3_REQUEST_FILE}/${TASK_3_REQUEST_FILE}/g" script.sh
sed -i "s/\${TASK_3_RESPONSE_FILE}/${TASK_3_RESPONSE_FILE}/g" script.sh

gcloud compute scp script.sh "lab-vm":~/ --zone "$ZONE" --project "$ID" -q
gcloud compute ssh "lab-vm" --zone "$ZONE" --project "$ID" --quiet --command "bash ~/script.sh"
```

## Lab Completed🎉