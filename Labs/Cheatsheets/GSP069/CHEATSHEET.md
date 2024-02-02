# **To be execute in Google Cloud Shell**

**1. Deploy PHP App**

    wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
    source common_code.sh

    if [ "$REGION" == "us-central1" ]; then
    REGION1=us-central
    else
    REGION1=$REGION
    fi

    git clone https://github.com/GoogleCloudPlatform/php-docs-samples.git

    cd php-docs-samples/appengine/standard/helloworld

    echo "Y" > a

    gcloud app create --region=$REGION1

    gcloud app deploy < a

## Lab Completed🎉