# **To be done using Google Cloud Console and Shell**

**1. Create a HTTP Function**

**2. Create a Cloud Storage Function**

**3. Create a Cloud Audit Logs Function**

**4. Create a VM Instance**

**5. Deploy different revisions**

**6. Set up minimum instances**

**7. Create a function with concurrency**

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud config set compute/region $REGION

gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  pubsub.googleapis.com

COLOR=yellow

BUCKET="gs://gcf-gen2-storage-$ID"
gsutil mb -l $REGION $BUCKET

SERVICE_ACCOUNT=$(gsutil kms serviceaccount -p $PROJECT_NUMBER)
gcloud projects add-iam-policy-binding $ID \
  --member serviceAccount:$SERVICE_ACCOUNT \
  --role roles/pubsub.publisher

deploy_1="gcloud functions deploy nodejs-http-function \
  --gen2 \
  --runtime nodejs16 \
  --entry-point helloWorld \
  --source . \
  --region $REGION \
  --trigger-http \
  --timeout 600s \
  --max-instances 1 \
  --quiet"

deploy_2="gcloud functions deploy nodejs-storage-function \
  --gen2 \
  --runtime nodejs16 \
  --entry-point helloStorage \
  --source . \
  --region $REGION \
  --trigger-bucket $BUCKET \
  --trigger-location $REGION \
  --max-instances 1"

deploy_3="gcloud functions deploy gce-vm-labeler \
  --gen2 \
  --runtime nodejs16 \
  --entry-point labelVmCreation \
  --source . \
  --region $REGION \
  --trigger-event-filters="type=google.cloud.audit.log.v1.written,serviceName=compute.googleapis.com,methodName=beta.compute.instances.insert" \
  --trigger-location $REGION \
  --max-instances 1"

deploy_4="gcloud functions deploy hello-world-colored \
  --gen2 \
  --runtime python39 \
  --entry-point hello_world \
  --source . \
  --region $REGION \
  --trigger-http \
  --allow-unauthenticated \
  --update-env-vars COLOR=$COLOR \
  --max-instances 1"

deploy_5="gcloud functions deploy slow-function \
  --gen2 \
  --runtime go116 \
  --entry-point HelloWorld \
  --source . \
  --region $REGION \
  --trigger-http \
  --allow-unauthenticated \
  --min-instances 1 \
  --max-instances 4"

deploy_6="gcloud functions deploy slow-concurrent-function \
  --gen2 \
  --runtime go116 \
  --entry-point HelloWorld \
  --source . \
  --region $REGION \
  --trigger-http \
  --allow-unauthenticated \
  --min-instances 1 \
  --max-instances 4"

mkdir ~/hello-http && cd $_

cat > index.js <<EOF
const functions = require('@google-cloud/functions-framework');
functions.http('helloWorld', (req, res) => {
  res.status(200).send('HTTP with Node.js in GCF 2nd gen!');
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

while true; do
  $deploy_1
  if [ $? -eq 0 ]; then
    echo -e '\033[1;31mFunction '\''nodejs-http-function'\'' deployed successfully!\033[0m'
    break
  else
    echo "Deploy failed, retrying..."
    sleep 5
  fi
done

mkdir ~/hello-storage && cd $_

cat > index.js <<EOF
const functions = require('@google-cloud/functions-framework');
functions.cloudEvent('helloStorage', (cloudevent) => {
  console.log('Cloud Storage event with Node.js in GCF 2nd gen!');
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

while true; do
  $deploy_2
  if [ $? -eq 0 ]; then
    echo -e '\033[1;31mFunction '\''nodejs-storage-function'\'' deployed successfully!\033[0m'
    break
  else
    echo "Deploy failed, retrying..."
    sleep 5
  fi
done

gcloud projects get-iam-policy $ID > /tmp/policy.yaml

echo -e "auditConfigs:\n- auditLogConfigs:\n  - logType: ADMIN_READ\n  - logType: DATA_READ\n  - logType: DATA_WRITE\n  service: compute.googleapis.com\n$(cat /tmp/policy.yaml)" > /tmp/temp_policy.yaml && mv /tmp/temp_policy.yaml /tmp/policy.yaml

gcloud projects set-iam-policy $ID /tmp/policy.yaml

gcloud projects add-iam-policy-binding $ID \
  --member serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
  --role roles/eventarc.eventReceiver

cd ~
git clone https://github.com/GoogleCloudPlatform/eventarc-samples.git

cd ~/eventarc-samples/gce-vm-labeler/gcf/nodejs

while true; do
  $deploy_3
  if [ $? -eq 0 ]; then
    echo -e '\033[1;31mFunction '\''gce-vm-labeler'\'' deployed successfully!\033[0m'
    break
  else
    echo "Deploy failed, retrying..."
    sleep 5
  fi
done

gcloud compute instances create instance-1 --zone=$ZONE

mkdir ~/hello-world-colored && cd $_

cat > main.py <<EOF
import os
color = os.environ.get('COLOR')
def hello_world(request):
    return f'<body style="background-color:{color}"><h1>Hello World!</h1></body>'
EOF

touch requirements.txt

while true; do
  $deploy_4
  if [ $? -eq 0 ]; then
    echo -e '\033[1;31mFunction '\''hello-world-colored'\'' deployed successfully!\033[0m'
    break
  else
    echo "Deploy failed, retrying..."
    sleep 5
  fi
done

mkdir ~/min-instances && cd $_

cat > main.go <<EOF
package p
import (
        "fmt"
        "net/http"
        "time"
)
func init() {
        time.Sleep(10 * time.Second)
}
func HelloWorld(w http.ResponseWriter, r *http.Request) {
        fmt.Fprint(w, "Slow HTTP Go in GCF 2nd gen!")
}
EOF

cat << 'EOF' > go.mod
module example.com/mod
go 1.16
EOF

while true; do
  $deploy_5
  if [ $? -eq 0 ]; then
    echo -e '\033[1;31mFunction '\''slow-function'\'' deployed successfully!\033[0m'
    break
  else
    echo "Deploy failed, retrying..."
    sleep 5
  fi
done

gcloud run deploy slow-function \
--image=$REGION-docker.pkg.dev/$ID/gcf-artifacts/slow--function:version_1 \
--max-instances=4 \
--region=$REGION \
--project=$ID \
 && gcloud run services update-traffic slow-function --to-latest --region=$REGION

sleep 7

gcloud run services delete slow-function --region $REGION -q

while true; do
  $deploy_6
  if [ $? -eq 0 ]; then
    echo -e '\033[1;31mFunction '\''slow-concurrent-function'\'' deployed successfully!\033[0m'
    break
  else
    echo "Deploy failed, retrying..."
    sleep 5
  fi
done

echo -e "\033[0;34mClick this link->\033[0m https://console.cloud.google.com/run/deploy/$REGION/slow-concurrent-function?cloudshell=false&project=$ID"
```
- Click on the link generated from the last cmd and navigate to `Cloud Run`.

- Under the Resources section, set the CPU to `1`.

- Under Requests, set the Maximum concurrent requests per instance to `100`.

- Under Autoscaling, set the Maximum number of instances to `4`.

- Leave the rest of the fields as default and click Deploy.
<!--
# Currently this code not giving green tick need to do this part manually
gcloud run deploy slow-concurrent-function \
--image=$REGION-docker.pkg.dev/$ID/gcf-artifacts/slow--concurrent--function:version_1 \
--concurrency=100 \
--cpu=1 \
--max-instances=4 \
--region=$REGION \
--project=$ID \
 && gcloud run services update-traffic slow-concurrent-function --to-latest --region=$REGION
-->

## Lab Completed🎉