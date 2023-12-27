# **To be done using Google Cloud Shell and Dialogflow**

## **Run in CloudShell**

    wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
    . common_code.sh

## **Go to [Diaglogflow](https://dialogflow.cloud.google.com/)**

- ### **Click on "Create Agent" and set**

- ### Agent Name:

      pigeon-travel 

- ### Default Time Zone:

    America/Denver

- ### Google Project: 
    
    select your Lab Project ID
   
- ### Use below cmd in Cloud Shell to get your project ID

      echo $ID

## **Click on the ⚙ (settings gear icon) next to your agent name**

- #### Click on "pigeon-travel" below and Download "pigeon-travel.zip"

    [pigeon-travel](https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Cheatsheets/GSP793/pigeon-travel.zip)

- #### Select the "Export and Import" tab.
- #### Click Import from zip.
- #### Select "pigeon-travel.zip"
- #### Type "IMPORT" to enable the import button
- #### Click "Import"
- #### Done

## Run Below Cmd in Google Cloud Shell and navigate to the link genrated from it

    echo https://dialogflow.cloud.google.com/#/agent/$ID/integrations

- #### Click on Dialogflow Phone Gateway
- #### Click Next -> Create

## Run in Google Cloud Shell

    wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/Labs/Cheatsheets/GSP793/pigeon-travel-gsp-793-cloud-function.zip

    gsutil mb gs://$ID
    gsutil cp pigeon-travel-gsp-793-cloud-function.zip gs://$ID

    gcloud functions deploy dialogflowFirebaseFulfillment \
    --runtime nodejs10 --trigger-http \
    --region=$REGION \
    --entry-point=dialogflowFirebaseFulfillment \
    --source gs://$ID/pigeon-travel-gsp-793-cloud-function.zip

### Lab Completed🎉