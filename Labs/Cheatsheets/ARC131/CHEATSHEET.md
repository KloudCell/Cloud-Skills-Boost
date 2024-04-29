# **To be done using Google Cloud Shell**

**1. Create an API key**

**2. Speech-to-Text transcription in English language**

**3. Speech-to-Text transcription in Spanish language**

- Need to create `API Key` manually for the `Green Tick` in `Task 1` from [Credentials](https://console.cloud.google.com/apis/credentials)

- Get `task_2_request_file` & `task_2_response_file` from [Task 2](https://www.cloudskillsboost.google/focuses/65993?parent=catalog#step6)

```
task_2_request_file=
```
```
task_2_response_file=
```
- Get `task_3_request_file` & `task_3_response_file` from [Task 3](https://www.cloudskillsboost.google/focuses/65993?parent=catalog#step7)

```
task_3_request_file=
```
```
task_3_response_file=
```

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

lab="lab-vm"

export API_KEY=$(gcloud beta services api-keys create --display-name='API key 1' 2>&1 >/dev/null | grep -o 'keyString":"[^"]*' | cut -d'"' -f3)

cat <<EOF > script.sh
#!/bin/bash

# Generate speech_request_en.json file
cat > "${task_2_request_file}" <<EOJSON
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

# Make API call for English transcription
curl -s -X POST -H "Content-Type: application/json" --data-binary @"${task_2_request_file}" \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > "${task_2_response_file}"

# Generate speech_request_sp.json file
cat > "${task_3_request_file}" <<EOJSON
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

# Make API call for Spanish transcription
curl -s -X POST -H "Content-Type: application/json" --data-binary @"${task_3_request_file}" \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > "${task_3_response_file}"
EOF

sed -i "s/<API_KEY>/${API_KEY}/g" script.sh
sed -i "s/<task_2_request_file>/${task_2_request_file}/g" script.sh
sed -i "s/<task_2_response_file>/${task_2_response_file}/g" script.sh
sed -i "s/<task_3_request_file>/${task_3_request_file}/g" script.sh
sed -i "s/<task_3_response_file>/${task_3_response_file}/g" script.sh

gcloud compute scp script.sh "$lab":~/ --zone "$ZONE" --project "$ID" -q
gcloud compute ssh "$lab" --zone "$ZONE" --project "$ID" --quiet --command "bash ~/script.sh"
```
## Lab Completed🎉