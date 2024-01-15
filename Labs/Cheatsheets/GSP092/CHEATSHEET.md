# **To be execute in Google Cloud Shell**

**1. Creating a Cloud Function**

**2. Create logs-based metric**
```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

echo "exports.helloWorld = (req, res) => {
  let message = req.query.message || req.body.message || 'Hello World!';
  res.status(200).send(message);
};" > index.js


echo '{
  "name": "sample-http",
  "version": "0.0.1"
}
' > package.json


gcloud functions deploy helloWorld \
--region $REGION \
--trigger-http \
--allow-unauthenticated \
--max-instances 5 \
--runtime nodejs16

gcloud logging metrics create CloudFunctionLatency-Logs --description="Number of high severity log entries" \
--log-filter='resource.type="cloud_function"
resource.labels.function_name="helloWorld"
logName="projects/$ID/logs/cloudfunctions.googleapis.com%2Fcloud-functions"'
```

## Lab Completed🎉