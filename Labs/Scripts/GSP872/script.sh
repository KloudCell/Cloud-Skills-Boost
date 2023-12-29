#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

# Setup and requirements

if (gcloud config set compute/region "$REGION" &&\

gcloud services enable apigateway.googleapis.com &&\

git clone https://github.com/GoogleCloudPlatform/nodejs-docs-samples.git &&\

cd nodejs-docs-samples/functions/helloworld/helloworldGet &&\

gcloud functions deploy helloGET --runtime nodejs14 --trigger-http --allow-unauthenticated --region $REGION --project $ID
)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Setup Completed: Checkpoint Completed (0/6)'

# Deploying an API backend

    if (gcloud functions describe helloGET --region $REGION &&\

    curl -v https://"$REGION"-"$ID".cloudfunctions.net/helloGET)

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Deployed API backend: Checkpoint Completed (1/6)'

# Test the API Backend

        if (cd ~
        wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Cheatsheets/GSP872/openapi2-functions.yaml 2> /dev/null &&\

        export API_ID="hello-world-$(cat /dev/urandom | tr -dc 'a-z' | fold -w ${1:-8} | head -n 1)" &&\

        sed -i "s/API_ID/${API_ID}/g" openapi2-functions.yaml &&\
        sed -i "s/PROJECT_ID/$ID/g" openapi2-functions.yaml &&\
        sed -i "s/REGION/$REGION/g" openapi2-functions.yaml)

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'API Tested: Checkpoint Completed (2/6)'

# Creating a gateway

            if (gcloud api-gateway apis create $API_ID --display-name="Hello World API" --project=$ID &&\

            gcloud api-gateway api-configs create hello-world-config --display-name="Hello World Config" \
            --api=$API_ID --openapi-spec=openapi2-functions.yaml \
            --project=$ID --backend-auth-service-account=$SERVICE &&\


            gcloud api-gateway gateways create hello-gateway --display-name="Hello Gateway" \
            --api=$API_ID --api-config=hello-world-config \
            --location=$REGION --project=$ID &&\

            export GATEWAY_URL=$(gcloud api-gateway gateways describe hello-gateway --location "$REGION" --format json | jq -r .defaultHostname) &&\

            echo -e "Your Gateway URL is : ${BRIGHT_RED}$GATEWAY_URL${NC}" &&\

            curl -s -w "\n" https://$GATEWAY_URL/hello)

            then
                printf "\n\e[1;96m%s\n\n\e[m" 'Gateway Created: Checkpoint Completed (3/6)'

# Securing access by using an API Key

                if (MANAGED_SERVICE=$(gcloud api-gateway apis list --format json | jq -r .[0].managedService | cut -d'/' -f6) &&\

                echo -e "Your Managed Service is : ${BRIGHT_RED}$MANAGED_SERVICE${NC}" &&\

                gcloud services enable $MANAGED_SERVICE &&\

                wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Cheatsheets/GSP872/openapi2-functions2.yaml 2> /dev/null &&\

                sed -i "s/API_ID/${API_ID}/g" openapi2-functions2.yaml &&\
                sed -i "s/PROJECT_ID/$ID/g" openapi2-functions2.yaml &&\
                sed -i "s/REGION/$REGION/g" openapi2-functions2.yaml)

                then
                    printf "\n\e[1;96m%s\n\n\e[m" 'Access Secured: Checkpoint Completed (4/6)'

# Create and deploy a new API config to your existing gateway

                    if (QWIKLAB=$ID@$ID.iam.gserviceaccount.com &&\

                    gcloud api-gateway api-configs create hello-config --display-name="Hello Config" \
                    --api=$API_ID --openapi-spec=openapi2-functions2.yaml \
                    --project=$ID --backend-auth-service-account=$QWIKLAB &&\

                    gcloud api-gateway gateways update hello-gateway \
                    --api=$API_ID \
                    --api-config=hello-config \
                    --location=$REGION \
                    --project=$ID)

                    then
                        printf "\n\e[1;96m%s\n\n\e[m" 'API config deployed: Checkpoint Completed (5/6)'

# Testing API call using API Key

                        if (export GATEWAY_URL=$(gcloud api-gateway gateways describe hello-gateway --location $REGION --format json | jq -r .defaultHostname) &&\
                        echo -e "Your Gateway URL is : ${BRIGHT_RED}$GATEWAY_URL${NC}" &&\

                        hello='' &&\
                        while [ "$hello" != "Hello World!" ]; do   hello=`curl -sL -w "\n" $GATEWAY_URL/hello?key=$API_KEY`;	echo $hello; done)

                        then
                            printf "\n\e[1;96m%s\n\n\e[m" 'API call tested: Checkpoint Completed (6/6)'
                        fi
                    fi
                fi
            fi
        fi
    fi
fi
    
printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all