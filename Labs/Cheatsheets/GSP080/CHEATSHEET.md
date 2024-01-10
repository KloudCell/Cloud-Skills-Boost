# **To be done using Google Cloud Console and Shell**

**1. Create a cloud storage bucket.**

**2. Deploy the function.**

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud config set compute/region $REGION

gsutil mb -p $ID gs://$ID

mkdir gcf_hello_world
cd gcf_hello_world

touch index.js

tee -a index.js <<EOF
/**
* Background Cloud Function to be triggered by Pub/Sub.
* This function is exported by index.js, and executed when
* the trigger topic receives a message.
*
* @param {object} data The event payload.
* @param {object} context The event metadata.
*/
exports.helloWorld = (data, context) => {
const pubSubMessage = data;
const name = pubSubMessage.data
    ? Buffer.from(pubSubMessage.data, 'base64').toString() : "Hello World";
console.log(`My Cloud Function: ${name}`);
};
EOF

gcloud functions deploy helloWorld \
  --stage-bucket $ID \
  --trigger-topic hello_world \
  --runtime nodejs20

gcloud functions describe helloWorld
```

## Lab Completed🎉