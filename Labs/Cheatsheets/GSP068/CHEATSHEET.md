# **To be execute in Google Cloud Shell**

**1. Deploy Java App**

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

if [ "$REGION" == "us-central1" ]; then
  REGION1=us-central
else
  REGION1=$REGION
fi

git clone https://github.com/GoogleCloudPlatform/java-docs-samples.git

cd java-docs-samples/appengine-java8/helloworld

gcloud app create --region=$REGION1

sed -i "s/myProjectId/$ID/g" pom.xml

mvn package appengine:deploy
```

## Lab Completed🎉