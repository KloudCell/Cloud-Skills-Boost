# **To be done using Google Cloud Shell**

**1. Create an API key**

**2. Make an entity analysis request and call Natural API**

**3. Create a Speech API request and call Speech API**

**4. Sentiment analysis with the Natural Language API**

- Go to [API & Services](https://console.cloud.google.com/apis/credentials?cloudshell=true) to create your `API Key`

```bash
ZONE=$(gcloud compute instances list --filter="name=lab-vm" --format "get(zone)" | awk -F/ '{print $NF}')
export API_KEY=$(gcloud beta services api-keys create --display-name='kloudcell' 2>&1 >/dev/null | grep -o 'keyString":"[^"]*' | cut -d'"' -f3)

cat > script.sh << ENDOF
#!/bin/bash

cat > nl_request.json <<EOF
{
  "document":{
    "type":"PLAIN_TEXT",
    "content":"With approximately 8.2 million people residing in Boston, the capital city of Massachusetts is one of the largest in the United States."
  },
  "encodingType":"UTF8"
}
EOF

curl "https://language.googleapis.com/v1/documents:analyzeEntities?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @nl_request.json > nl_response.json
 
cat > speech_request.json <<EOF
{
  "config": {
      "encoding":"FLAC",
      "languageCode": "en-US"
  },
  "audio": {
      "uri":"gs://cloud-samples-tests/speech/brooklyn.flac"
  }
}
EOF

curl -s -X POST -H "Content-Type: application/json" --data-binary @speech_request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > speech_response.json

cat > sentiment_analysis.py <<EOF
import argparse

from google.cloud import language_v1

def print_result(annotations):
    score = annotations.document_sentiment.score
    magnitude = annotations.document_sentiment.magnitude

    for index, sentence in enumerate(annotations.sentences):
        sentence_sentiment = sentence.sentiment.score
        print(
            f"Sentence {index} has a sentiment score of {sentence_sentiment}"
        )

    print(
        f"Overall Sentiment: score of {score} with magnitude of {magnitude}"
    )
    return 0

def analyze(movie_review_filename):
    """Run a sentiment analysis request on text within a passed filename."""
    client = language_v1.LanguageServiceClient()

    with open(movie_review_filename) as review_file:
        # Instantiates a plain text document.
        content = review_file.read()

    document = language_v1.Document(
        content=content, type_=language_v1.Document.Type.PLAIN_TEXT
    )
    annotations = client.analyze_sentiment(request={"document": document})

    # Print the results
    print_result(annotations)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "movie_review_filename",
        help="The filename of the movie review you'd like to analyze.",
    )
    args = parser.parse_args()

    analyze(args.movie_review_filename)
EOF

gsutil cp gs://cloud-samples-tests/natural-language/sentiment-samples.tgz .

gunzip sentiment-samples.tgz
tar -xvf sentiment-samples.tar

python3 sentiment_analysis.py reviews/bladerunner-pos.txt
ENDOF

gcloud compute ssh --zone "$ZONE" "lab-vm" --command "bash -s" < script.sh -q
```

## Lab Completed🎉