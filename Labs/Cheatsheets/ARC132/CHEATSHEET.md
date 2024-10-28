# **To be done using Google Cloud Shell**

**1. Create an API key**

**2. Create synthetic speech from text**

**3. Speech-to-Text transcription in French language**

**4. Translate Text with the Cloud Translation API**

**5. Detect language with the Cloud Translation API**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud beta services api-keys create --display-name="KloudCell" 2> output.txt
API_KEY=$(grep -oP '"keyString":"\K[^"]+' output.txt)

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
read -p "Enter file name from 'Task 2':" TASK_2_RESPONSE_FILE

read -p "Enter 'request file' name from 'Task 3':" TASK_3_REQUEST_FILE

read -p "Enter 'response file' name from 'Task 3':" TASK_3_RESPONSE_FILE

read -p "Enter the 'sentence' from 'Task 4':" TASK_4_REQUEST_SENTENCE

read -p "Enter response file' name from 'Task 4':" TASK_4_RESPONSE_FILE

read -p "Enter the 'sentence' from 'Task 5':" TASK_5_REQUEST_SENTENCE

read -p "Enter response file' name from 'Task 5':" TASK_5_RESPONSE_FILE

cat > var.sh << EOF
API_KEY=$API_KEY
TASK_2_RESPONSE_FILE=$TASK_2_RESPONSE_FILE
TASK_3_REQUEST_FILE=$TASK_3_REQUEST_FILE
TASK_3_RESPONSE_FILE=$TASK_3_RESPONSE_FILE
TASK_4_REQUEST_SENTENCE=$TASK_4_REQUEST_SENTENCE
TASK_4_RESPONSE_FILE=$TASK_4_RESPONSE_FILE
TASK_5_REQUEST_SENTENCE=$TASK_5_REQUEST_SENTENCE
TASK_5_RESPONSE_FILE=$TASK_5_RESPONSE_FILE
EOF

cat << 'EOFD' > script.sh
source venv/bin/activate

cat << 'EOF' > synthesize-text.json
{
    'input':{
        'text':'Cloud Text-to-Speech API allows developers to include
           natural-sounding, synthetic human speech as playable audio in
           their applications. The Text-to-Speech API converts text or
           Speech Synthesis Markup Language (SSML) input into audio data
           like MP3 or LINEAR16 (the encoding used in WAV files).'
    },
    'voice':{
        'languageCode':'en-gb',
        'name':'en-GB-Standard-A',
        'ssmlGender':'FEMALE'
    },
    'audioConfig':{
        'audioEncoding':'MP3'
    }
}
EOF

curl -H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
  -H "Content-Type: application/json; charset=utf-8" \
  -d @synthesize-text.json "https://texttospeech.googleapis.com/v1/text:synthesize" \
  > $TASK_2_RESPONSE_FILE

cat << 'EOF' > tts_decode.py
import argparse
from base64 import decodebytes
import json
"""
Usage:
        python tts_decode.py --input "synthesize-text.txt" \
        --output "synthesize-text-audio.mp3"
"""
def decode_tts_output(input_file, output_file):
    """ Decode output from Cloud Text-to-Speech.
    input_file: the response from Cloud Text-to-Speech
    output_file: the name of the audio file to create
    """
    with open(input_file) as input:
        response = json.load(input)
        audio_data = response['audioContent']
        with open(output_file, "wb") as new_file:
            new_file.write(decodebytes(audio_data.encode('utf-8')))
if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Decode output from Cloud Text-to-Speech",
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--input',
                       help='The response from the Text-to-Speech API.',
                       required=True)
    parser.add_argument('--output',
                       help='The name of the audio file to create',
                       required=True)
    args = parser.parse_args()
    decode_tts_output(args.input, args.output)
EOF

python tts_decode.py --input "$TASK_2_RESPONSE_FILE" --output "synthesize-text-audio.mp3"

cat << 'EOF' > "$TASK_3_REQUEST_FILE"
{
  "config": {
    "encoding": "FLAC",
    "sampleRateHertz": 44100,
    "languageCode": "fr-FR"
  },
  "audio": {
    "uri": "gs://cloud-samples-data/speech/corbeau_renard.flac"
  }
}
EOF

curl -s -X POST -H "Content-Type: application/json" \
    --data-binary @"$TASK_3_REQUEST_FILE" \
    "https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" \
    -o "$TASK_3_RESPONSE_FILE"

sudo apt-get update
sudo apt-get install -y jq

curl "https://translation.googleapis.com/language/translate/v2?target=en&key=${API_KEY}&q=${TASK_4_REQUEST_SENTENCE}" > "$TASK_4_RESPONSE_FILE"

decoded_sentence=$(python -c "import urllib.parse; print(urllib.parse.unquote('$TASK_5_REQUEST_SENTENCE'))")

curl -s -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "{\"q\": [\"$decoded_sentence\"]}" \
  "https://translation.googleapis.com/language/translate/v2/detect?key=${API_KEY}" \
  -o "$TASK_5_RESPONSE_FILE"
EOFD

gcloud compute scp var.sh script.sh lab-vm:~ --zone $ZONE -q
gcloud compute ssh --zone "$ZONE" "lab-vm" -q --command ". var.sh && . script.sh"
```

## Lab Completed🎉