# **To be execute in Google Cloud Shell**

**Deploy a Go App**

    git clone https://github.com/GoogleCloudPlatform/golang-samples.git

    cd golang-samples/appengine/go11x/helloworld

    echo "Y" > a

    sudo apt-get install google-cloud-sdk-app-engine-go

    gcloud app create --region=us-central

    gcloud app deploy < a
