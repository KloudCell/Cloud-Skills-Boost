# **To be done using Google Cloud Shell**

**1. Create an API Key**

**2. Make an Entity Analysis Request**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

gcloud iam service-accounts create my-natlang-sa \
    --display-name "my natural language service account"

gcloud iam service-accounts keys create key.json \
    --iam-account my-natlang-sa@${ID}.iam.gserviceaccount.com

export GOOGLE_APPLICATION_CREDENTIALS="key.json"

gcloud compute ssh linux-instance --zone $ZONE -q --command 'gcloud ml language analyze-entities --content="Michelangelo Caravaggio, Italian painter, is known for \"The Calling of Saint Matthew\"." > result.json'
```

## Lab Completed🎉