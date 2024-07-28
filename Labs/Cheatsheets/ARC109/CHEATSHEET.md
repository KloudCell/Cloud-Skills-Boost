# **To be done using Google Cloud Shell**

**1. Create a Cloud Function**

**2. Create an API Gateway**

**3. Create a Pub/Sub Topic and Publish Messages via API Backend**
 
```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud services enable apigateway.googleapis.com

sleep 7

export API_ID="gcfunction-api-$(cat /dev/urandom | tr -dc 'a-z' | fold -w ${1:-8} | head -n 1)"

cat > index.js <<EOF
/**
 * Responds to any HTTP request.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */
exports.helloWorld = (req, res) => {
  let message = req.query.message || req.body.message || 'Hello World!';
  res.status(200).send(message);
};
EOF

cat > package.json <<EOF
{
  "name": "sample-http",
  "version": "0.0.1"
}
EOF

success=false

while [ "$success" != "true" ]; do
    gcloud functions deploy GCFunction \
    --gen2 \
    --runtime=nodejs20 \
    --trigger-http \
    --allow-unauthenticated \
    --entry-point=helloWorld \
    --region=$REGION \
    --max-instances 5 \
    --source=./ \
    --quiet

    if [ $? -eq 0 ]; then
        echo "Deployment successful."
        success=true
    else
        echo "Deployment failed. Retrying..."
        sleep 12
    fi
done

gcloud functions add-invoker-policy-binding GCFunction \
    --region=$REGION \
    --member="allUsers"

cat > openapispec.yaml <<EOF
swagger: '2.0'
info:
  title: GCFunction API
  description: Sample API on API Gateway with a Google Cloud Functions backend
  version: 1.0.0
schemes:
  - https
produces:
  - application/json
paths:
  /GCFunction:
    get:
      summary: gcfunction
      operationId: gcfunction
      x-google-backend:
        address: https://$REGION-$ID.cloudfunctions.net/GCFunction
      responses:
       '200':
          description: A successful response
          schema:
            type: string
EOF

gcloud api-gateway apis create $API_ID --project=$ID

gcloud api-gateway api-configs create gcfunction-api \
  --api=$API_ID \
  --openapi-spec=openapispec.yaml \
  --project=$ID \
  --backend-auth-service-account=$PROJECT_NUMBER-compute@developer.gserviceaccount.com

gcloud api-gateway gateways create gcfunction-api \
--api=$API_ID \
--api-config=gcfunction-api \
--location=$REGION \
--project=$ID

gcloud pubsub topics create demo-topic

cat > index.js <<EOF
/**
 * Responds to any HTTP request.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */
const {PubSub} = require('@google-cloud/pubsub');
const pubsub = new PubSub();
const topic = pubsub.topic('demo-topic');
exports.helloWorld = (req, res) => {
  
  // Send a message to the topic
  topic.publishMessage({data: Buffer.from('Hello from Cloud Functions!')});
  res.status(200).send("Message sent to Topic demo-topic!");
};
EOF

cat > package.json <<EOF
{
  "name": "sample-http",
  "version": "0.0.1",
  "dependencies": {
    "@google-cloud/pubsub": "^3.4.1"
  }
}
EOF

success=false

while [ "$success" != "true" ]; do
    gcloud functions deploy GCFunction \
    --runtime=nodejs20 \
    --trigger-http \
    --allow-unauthenticated \
    --entry-point=helloWorld \
    --region=$REGION \
    --max-instances 5 \
    --source=./ \
    --quiet

    if [ $? -eq 0 ]; then
        echo "Deployment successful."
        success=true
    else
        echo "Deployment failed. Retrying..."
        sleep 12
    fi
done
```

## Lab Completed🎉