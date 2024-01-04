# **To be done using Google Cloud Console and Shell**

**Setup and requirements**

    wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
    . common_code.sh

    gcloud config set compute/region "$REGION"

    gcloud services enable apigateway.googleapis.com

    git clone https://github.com/GoogleCloudPlatform/nodejs-docs-samples.git

    cd nodejs-docs-samples/functions/helloworld/helloworldGet

    gcloud functions deploy helloGET --runtime nodejs14 --trigger-http --allow-unauthenticated --region $REGION --project $ID

**1. Deploying an API backend**

    gcloud functions describe helloGET --region $REGION

    curl -v https://"$REGION"-"$ID".cloudfunctions.net/helloGET

**2. Test the API Backend**

    cd ~
    wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Cheatsheets/GSP872/openapi2-functions.yaml 2> /dev/null

    export API_ID="hello-world-$(cat /dev/urandom | tr -dc 'a-z' | fold -w ${1:-8} | head -n 1)"

    sed -i "s/API_ID/${API_ID}/g" openapi2-functions.yaml
    sed -i "s/PROJECT_ID/$ID/g" openapi2-functions.yaml
    sed -i "s/REGION/$REGION/g" openapi2-functions.yaml

**3. Creating a gateway**

    gcloud api-gateway apis create $API_ID --display-name="Hello World API" --project=$ID

    gcloud api-gateway api-configs create hello-world-config --display-name="Hello World Config" \
    --api=$API_ID --openapi-spec=openapi2-functions.yaml \
    --project=$ID --backend-auth-service-account=$SERVICE


    gcloud api-gateway gateways create hello-gateway --display-name="Hello Gateway" \
    --api=$API_ID --api-config=hello-world-config \
    --location=$REGION --project=$ID

    export GATEWAY_URL=$(gcloud api-gateway gateways describe hello-gateway --location "$REGION" --format json | jq -r .defaultHostname)

    echo -e "Your Gateway URL is : ${BRIGHT_RED}$GATEWAY_URL${NC}"

    curl -s -w "\n" https://$GATEWAY_URL/hello

**4. Securing access by using an API Key**

    MANAGED_SERVICE=$(gcloud api-gateway apis list --format json | jq -r .[0].managedService | cut -d'/' -f6)
    
    echo -e "Your Managed Service is : ${BRIGHT_RED}$MANAGED_SERVICE${NC}"

    gcloud services enable $MANAGED_SERVICE

    wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Cheatsheets/GSP872/openapi2-functions2.yaml 2> /dev/null

    sed -i "s/API_ID/${API_ID}/g" openapi2-functions2.yaml
    sed -i "s/PROJECT_ID/$ID/g" openapi2-functions2.yaml
    sed -i "s/REGION/$REGION/g" openapi2-functions2.yaml

**5. Create and deploy a new API config to your existing gateway**

    QWIKLAB=$ID@$ID.iam.gserviceaccount.com

    gcloud api-gateway api-configs create hello-config --display-name="Hello Config" \
    --api=$API_ID --openapi-spec=openapi2-functions2.yaml \
    --project=$ID --backend-auth-service-account=$QWIKLAB

    gcloud api-gateway gateways update hello-gateway \
    --api=$API_ID \
    --api-config=hello-config \
    --location=$REGION \
    --project=$ID


**6. Testing API call using API Key**

    export GATEWAY_URL=$(gcloud api-gateway gateways describe hello-gateway --location $REGION --format json | jq -r .defaultHostname)
    echo -e "Your Gateway URL is : ${BRIGHT_RED}$GATEWAY_URL${NC}"

    hello=''
    while [ "$hello" != "Hello World!" ]; do   hello=`curl -sL -w "\n" $GATEWAY_URL/hello?key=$API_KEY`;	echo $hello; done

## Lab Completed🎉