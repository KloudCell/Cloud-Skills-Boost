# **To be done using Google Cloud Shell**

**1. Create a Cloud Storage bucket**

**2. Create cloud storage function**

**3. Create and deploy a HTTP function**

- Get these values from below your `Login Credential`

```bash
read -p "Enter HTTP Function Name:" HTTP_FUNCTION
read -p "Enter Cloud Storage Function Name:" FUNCTION_NAME

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

export VERSION=$(gcloud functions runtimes list --filter='name~^node' --format='value(name)' --region $REGION| sort -V | tail -n 1)

gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  pubsub.googleapis.com

SERVICE_ACCOUNT=$(gsutil kms serviceaccount -p $PROJECT_NUMBER)
gcloud projects add-iam-policy-binding $ID \
  --member serviceAccount:$SERVICE_ACCOUNT \
  --role roles/pubsub.publisher

gsutil mb -l $REGION gs://$ID
export BUCKET="gs://$ID"

mkdir ~/$FUNCTION_NAME && cd $_

cat > index.js <<EOF
const functions = require('@google-cloud/functions-framework');
functions.cloudEvent('$FUNCTION_NAME', (cloudevent) => {
  console.log('A new event in your Cloud Storage bucket has been logged!');
  console.log(cloudevent);
});
EOF

cat > package.json <<EOF
{
  "name": "nodejs-functions-gen2-codelab",
  "version": "0.0.1",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/functions-framework": "^2.0.0"
  }
}
EOF

deploy_1() {
gcloud functions deploy $FUNCTION_NAME \
  --gen2 \
  --runtime ${VERSION} \
  --entry-point $FUNCTION_NAME \
  --source . \
  --region $REGION \
  --trigger-bucket $BUCKET \
  --trigger-location $REGION \
  --max-instances 2
}

while ! deploy_1; do
    echo "Error occurred. Retrying in a few seconds..."
    sleep 7
done
echo "Function successfully deployed!"
cd ..

mkdir ~/HTTP_FUNCTION && cd $_

cat > index.js <<EOF
const functions = require('@google-cloud/functions-framework');
functions.http('$HTTP_FUNCTION', (req, res) => {
  res.status(200).send('subscribe to quikclab');
});
EOF

cat > package.json <<EOF
{
  "name": "nodejs-functions-gen2-codelab",
  "version": "0.0.1",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/functions-framework": "^2.0.0"
  }
}
EOF

deploy_2() {
gcloud functions deploy $HTTP_FUNCTION \
  --gen2 \
  --runtime ${VERSION} \
  --entry-point $HTTP_FUNCTION \
  --source . \
  --region $REGION \
  --trigger-http \
  --timeout 600s \
  --max-instances 2 \
  --min-instances 1 -q
}

while ! deploy_2; do
    echo "Error occurred. Retrying in a few seconds..."
    sleep 7
done
echo "Function successfully deployed!"
```

## Lab Completed🎉