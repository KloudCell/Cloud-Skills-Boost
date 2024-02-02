# **To be execute in Google Cloud Shell**

**1. Deploy Go App**

    wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
    source common_code.sh

    if [ "$REGION" == "us-central1" ]; then
    REGION1=us-central
    else
    REGION1=$REGION
    fi

    git clone https://github.com/GoogleCloudPlatform/golang-samples.git

    cd golang-samples/appengine/go11x/helloworld

    echo "Y" > a

    sudo apt-get install google-cloud-sdk-app-engine-go

    gcloud app create --region=$REGION1

    gcloud app deploy < a

## Lab Completed🎉