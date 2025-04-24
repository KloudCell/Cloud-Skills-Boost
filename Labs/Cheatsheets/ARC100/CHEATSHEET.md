# **To be done using Google Cloud Shell**

**1. Create a bucket**

**2. Create a Pub/Sub topic**

**3. Create the Cloud Function**

- Get `TOPIC NAME` from [Task 2](https://www.cloudskillsboost.google/games/5044/labs/32922#step6)

- Get `FUNCTION_NAME` from [Task 3](https://www.cloudskillsboost.google/games/5044/labs/32922#step7)

```bash
echo "Please enter the TOPIC_NAME:"
read TOPIC_NAME

echo "Please enter the FUNCTION_NAME:"
read FUNCTION_NAME

echo -e "You entered the following values:"
echo -e "\033[0;32mTOPIC_NAME:\033[0m \033[1;35m$TOPIC_NAME\033[0m"
echo -e "\033[0;32mFUNCTION_NAME:\033[0m \033[1;35m$FUNCTION_NAME\033[0m"

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

export VERSION=$(gcloud functions runtimes list --filter='name~^node' --format='value(name)' --region $REGION| sort -V | tail -n 1)

BUCKET=memories-bucket-$ID
KMS_SERVICE_ACCOUNT=$(gsutil kms serviceaccount -p $PROJECT_NUMBER)

gcloud services enable run.googleapis.com \
eventarc.googleapis.com

gcloud projects add-iam-policy-binding $ID \
  --member serviceAccount:$KMS_SERVICE_ACCOUNT \
  --role roles/pubsub.publisher

gsutil mb  -l $REGION gs://$BUCKET

gcloud pubsub topics create $TOPIC_NAME

cat <<'EOF'> index.js
const functions = require('@google-cloud/functions-framework');
const crc32 = require("fast-crc32c");
const { Storage } = require('@google-cloud/storage');
const gcs = new Storage();
const { PubSub } = require('@google-cloud/pubsub');
const imagemagick = require("imagemagick-stream");

functions.cloudEvent('FUNCTION_NAME', cloudEvent => {
  const event = cloudEvent.data;

  console.log(`Event: ${event}`);
  console.log(`Hello ${event.bucket}`);

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
});
EOF

sed -i "s/TOPIC_NAME/${TOPIC_NAME}/g" index.js
sed -i "s/FUNCTION_NAME/${FUNCTION_NAME}/g" index.js

cat <<'EOF'> package.json
{
  "name": "thumbnails",
  "version": "1.0.0",
  "description": "Create Thumbnail of uploaded image",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0",
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

deploy() {
  gcloud functions deploy $FUNCTION_NAME \
  --gen2 \
  --runtime=${VERSION} \
  --region=$REGION \
  --source=. \
  --entry-point=$FUNCTION_NAME \
  --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
  --trigger-event-filters="bucket=$BUCKET"
}

while ! deploy; do
  echo -e "\033[0;31mDeployment failed\033[0m. Retrying again in a few seconds..."
  sleep 12
done

echo -e "\033[0;32mDeployment succeeded\033[0m!"

wget https://storage.googleapis.com/cloud-training/gsp315/map.jpg

sleep 12

gsutil cp map.jpg gs://$BUCKET/map.jpg
```
## Lab Completed🎉