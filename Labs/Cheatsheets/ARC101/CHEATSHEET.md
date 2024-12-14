# **To be done using Google Cloud Shell**

**1. Create a Cloud Storage bucket**

**2. Create a Pub/Sub topic**

**3. Create a Cloud Function**

**4. Create an alerting policy**

- Get these values from below your `Login Credential`

```bash
echo "Please enter the BUCKET NAME:"
read BUCKET_NAME

echo "Please enter the TOPIC_NAME:"
read TOPIC_NAME

echo "Please enter the FUNCTION_NAME:"
read FUNCTION_NAME

echo -e "You entered the following values:"
echo -e "\033[0;32mBUCKET_NAME:\033[0m \033[1;35m$BUCKET_NAME\033[0m"
echo -e "\033[0;32mTOPIC_NAME:\033[0m \033[1;35m$TOPIC_NAME\033[0m"
echo -e "\033[0;32mFUNCTION_NAME:\033[0m \033[1;35m$FUNCTION_NAME\033[0m"

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

USER_NAME_2=$(gcloud projects get-iam-policy $ID --format="json" | jq -r --arg USER_NAME "$USER_NAME" '.bindings[] | select(.role == "roles/viewer") | .members[] | select(startswith("user:")) | select(. != "user:" + $USER_NAME) | sub("user:"; "")')

gsutil mb -p $ID gs://$BUCKET_NAME

gcloud projects add-iam-policy-binding $ID \
--member=user:$USER_NAME_2 \
--role=roles/storage.objectViewer

gcloud pubsub topics create $TOPIC_NAME

cat << 'EOF' > index.js
/* globals exports, require */
//jshint strict: false
//jshint esversion: 6
"use strict";
const crc32 = require("fast-crc32c");
const { Storage } = require('@google-cloud/storage');
const gcs = new Storage();
const { PubSub } = require('@google-cloud/pubsub');
const imagemagick = require("imagemagick-stream");

exports.thumbnail = (event, context) => {
  const fileName = event.name;
  const bucketName = event.bucket;
  const size = "64x64"
  const bucket = gcs.bucket(bucketName);
  const topicName = "TOPIC_NAME";
  const pubsub = new PubSub();
  if ( fileName.search("64x64_thumbnail") == -1 ){
    // doesn't have a thumbnail, get the filename extension
    var filename_split = fileName.split('.');
    var filename_ext = filename_split[filename_split.length - 1];
    var filename_without_ext = fileName.substring(0, fileName.length - filename_ext.length );
    if (filename_ext.toLowerCase() == 'png' || filename_ext.toLowerCase() == 'jpg'){
      // only support png and jpg at this point
      console.log(`Processing Original: gs://${bucketName}/${fileName}`);
      const gcsObject = bucket.file(fileName);
      let newFilename = filename_without_ext + size + '_thumbnail.' + filename_ext;
      let gcsNewObject = bucket.file(newFilename);
      let srcStream = gcsObject.createReadStream();
      let dstStream = gcsNewObject.createWriteStream();
      let resize = imagemagick().resize(size).quality(90);
      srcStream.pipe(resize).pipe(dstStream);
      return new Promise((resolve, reject) => {
        dstStream
          .on("error", (err) => {
            console.log(`Error: ${err}`);
            reject(err);
          })
          .on("finish", () => {
            console.log(`Success: ${fileName} → ${newFilename}`);
              // set the content-type
              gcsNewObject.setMetadata(
              {
                contentType: 'image/'+ filename_ext.toLowerCase()
              }, function(err, apiResponse) {});
              pubsub
                .topic(topicName)
                .publisher()
                .publish(Buffer.from(newFilename))
                .then(messageId => {
                  console.log(`Message ${messageId} published.`);
                })
                .catch(err => {
                  console.error('ERROR:', err);
                });
          });
      });
    }
    else {
      console.log(`gs://${bucketName}/${fileName} is not an image I can handle`);
    }
  }
  else {
    console.log(`gs://${bucketName}/${fileName} already has a thumbnail`);
  }
};
EOF

sed -i "s/TOPIC_NAME/${TOPIC_NAME}/g" index.js

cat << 'EOF' > package.json
{
    "name": "thumbnails",
    "version": "1.0.0",
    "description": "Create Thumbnail of uploaded image",
    "scripts": {
      "start": "node index.js"
    },
    "dependencies": {
      "@google-cloud/pubsub": "^2.0.0",
      "@google-cloud/storage": "^5.0.0",
      "fast-crc32c": "1.0.4",
      "imagemagick-stream": "4.1.1"
    },
    "devDependencies": {},
    "engines": {
      "node": ">=4.3.2"
    }
  }
EOF

SA=$(gsutil kms serviceaccount -p $PROJECT_NUMBER)

DEPLOY_COMMAND="gcloud functions deploy $FUNCTION_NAME \
--runtime=nodejs14 \
--region=$REGION \
--source=. \
--entry-point=thumbnail \
--trigger-bucket $BUCKET_NAME"

IAM_COMMAND="gcloud projects add-iam-policy-binding $ID \
--member serviceAccount:$SA \
--role roles/artifactregistry.reader"

$DEPLOY_COMMAND

while [ $? -ne 0 ]; do
    echo "Deployment failed. Granting IAM permissions and retrying..."
    $IAM_COMMAND
    $DEPLOY_COMMAND
done

echo "Deployment successful!"

wget https://storage.googleapis.com/cloud-training/arc101/travel.jpg

gsutil cp travel.jpg gs://$BUCKET_NAME

cat << 'EOF' > app-engine-error-percent-policy.json 
{
    "displayName": "Active Cloud Function Instances",
    "userLabels": {},
    "conditions": [
      {
        "displayName": "Cloud Function - Active instances",
        "conditionThreshold": {
          "filter": "resource.type = \"cloud_function\" AND metric.type = \"cloudfunctions.googleapis.com/function/active_instances\"",
          "aggregations": [
            {
              "alignmentPeriod": "300s",
              "crossSeriesReducer": "REDUCE_NONE",
              "perSeriesAligner": "ALIGN_MEAN"
            }
          ],
          "comparison": "COMPARISON_GT",
          "duration": "0s",
          "trigger": {
            "count": 1
          },
          "thresholdValue": 1
        }
      }
    ],
    "alertStrategy": {
      "autoClose": "604800s"
    },
    "combiner": "OR",
    "enabled": true,
    "notificationChannels": [],
    "severity": "SEVERITY_UNSPECIFIED"
  }
EOF

gcloud alpha monitoring policies create --policy-from-file="app-engine-error-percent-policy.json"
```

## Lab Completed🎉