# **To be done using Google Cloud Shell**

**1. Deploying an API backend**

**2. Test the API Backend**

**3. Creating a gateway**

**4. Securing access by using an API Key**

**5. Create and deploy a new API config to your existing gateway**

**6. Testing API call using API Key**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh
export API_KEY=$(gcloud beta services api-keys create --display-name='KloudCell' 2>&1 >/dev/null | grep -o 'keyString":"[^"]*' | cut -d'"' -f3)

gcloud config set compute/region "$REGION"

gcloud services enable apigateway.googleapis.com

git clone https://github.com/GoogleCloudPlatform/nodejs-docs-samples.git

cd nodejs-docs-samples/functions/helloworld/helloworldGet

deploy() {
gcloud functions deploy helloGET --runtime nodejs20 --trigger-http --allow-unauthenticated --region $REGION --project $ID
}

while ! deploy; do
    echo "Error occurred. Retrying in a few seconds..."
    sleep 7
done
echo "'helloGET' Deployed Successfully!"

curl -v https://"$REGION"-"$ID".cloudfunctions.net/helloGET

cd ~
cat << 'EOF' > openapi2-functions.yaml
# openapi2-functions.yaml
swagger: '2.0'
info:
  title: API_ID description
  description: Sample API on API Gateway with a Google Cloud Functions backend
  version: 1.0.0
schemes:
  - https
produces:
  - application/json
paths:
  /hello:
    get:
      summary: Greet a user
      operationId: hello
      x-google-backend:
        address: https://REGION-PROJECT_ID.cloudfunctions.net/helloGET
      responses:
       '200':
          description: A successful response
          schema:
            type: string
EOF

export API_ID="hello-world-$(cat /dev/urandom | tr -dc 'a-z' | fold -w ${1:-8} | head -n 1)"

sed -i "s/API_ID/${API_ID}/g" openapi2-functions.yaml
sed -i "s/PROJECT_ID/$ID/g" openapi2-functions.yaml
sed -i "s/REGION/$REGION/g" openapi2-functions.yaml

gcloud api-gateway apis create $API_ID --display-name="Hello World API" --project=$ID

gcloud api-gateway api-configs create hello-world-config \
--display-name="Hello World Config" \
--api=$API_ID \
--openapi-spec=openapi2-functions.yaml \
--project=$ID \
--backend-auth-service-account=$SERVICE

gcloud api-gateway gateways create hello-gateway \
--display-name="Hello Gateway" \
--api=$API_ID \
--api-config=hello-world-config \
--location=$REGION \
--project=$ID

export GATEWAY_URL=$(gcloud api-gateway gateways describe hello-gateway --location "$REGION" --format json | jq -r .defaultHostname)

echo -e "Your Gateway URL is : ${BRIGHT_RED}$GATEWAY_URL${NC}"

curl -s -w "\n" https://$GATEWAY_URL/hello

MANAGED_SERVICE=$(gcloud api-gateway apis list --format json | jq -r .[0].managedService | cut -d'/' -f6)

echo -e "Your Managed Service is : ${BRIGHT_RED}$MANAGED_SERVICE${NC}"

gcloud services enable $MANAGED_SERVICE

cat << 'EOF' > openapi2-functions2.yaml
# openapi2-functions.yaml
swagger: '2.0'
info:
  title: API_ID description
  description: Sample API on API Gateway with a Google Cloud Functions backend
  version: 1.0.0
schemes:
  - https
produces:
  - application/json
paths:
  /hello:
    get:
      summary: Greet a user
      operationId: hello
      x-google-backend:
        address: https://REGION-PROJECT_ID.cloudfunctions.net/helloGET
      security:
        - api_key: []
      responses:
       '200':
          description: A successful response
          schema:
            type: string
securityDefinitions:
  api_key:
    type: "apiKey"
    name: "key"
    in: "query"
EOF

sed -i "s/API_ID/${API_ID}/g" openapi2-functions2.yaml
sed -i "s/PROJECT_ID/$ID/g" openapi2-functions2.yaml
sed -i "s/REGION/$REGION/g" openapi2-functions2.yaml

gcloud api-gateway api-configs create hello-config \
--display-name="Hello Config" \
--api=$API_ID \
--openapi-spec=openapi2-functions2.yaml \
--project=$ID \
--backend-auth-service-account=$QWIKLABS_SERVICE

gcloud api-gateway gateways update hello-gateway \
--api=$API_ID \
--api-config=hello-config \
--location=$REGION \
--project=$ID

export GATEWAY_URL=$(gcloud api-gateway gateways describe hello-gateway --location $REGION --format json | jq -r .defaultHostname)

echo -e "Your Gateway URL is : ${BRIGHT_RED}$GATEWAY_URL${NC}"

hello=''
while [ "$hello" != "Hello World!" ]; do   hello=`curl -sL -w "\n" $GATEWAY_URL/hello?key=$API_KEY`;	echo $hello; done
```

## Lab Completed🎉