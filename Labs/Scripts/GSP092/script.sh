#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

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

# Creating a Cloud Function
if (gcloud functions deploy helloWorld \
--region $REGION \
--trigger-http \
--allow-unauthenticated \
--max-instances 5 \
--runtime nodejs16)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'API Key Created: Checkpoint Completed (1/2)'

# Create logs-based metric
    if (gcloud logging metrics create CloudFunctionLatency-Logs --description="Number of high severity log entries" \
    --log-filter='resource.type="cloud_function"
    resource.labels.function_name="helloWorld"
    logName="projects/$ID/logs/cloudfunctions.googleapis.com%2Fcloud-functions"')

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'API Key Created: Checkpoint Completed (2/2)'
    fi
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all