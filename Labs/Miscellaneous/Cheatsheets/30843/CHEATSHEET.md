# **To be done using Google Cloud Shell**

**1. Public Cloud Run Service**

**2. Create service account**

**3. Minimum balance log entry of 500**

**4. Minimum balance log entry of 700**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud services enable run.googleapis.com
gcloud config set run/region $REGION

gcloud run deploy billing-service \
--image gcr.io/qwiklabs-resources/gsp723-parking-service \
--region $REGION \
--allow-unauthenticated

gcloud iam service-accounts create billing-initiator --display-name="Billing Initiator"

while true; do
    gcloud projects add-iam-policy-binding $ID --member="serviceAccount:billing-initiator@$ID.iam.gserviceaccount.com" --role="roles/run.invoker"
    if [ $? -eq 0 ]; then
        echo "Command executed successfully"
        break
    else
        echo "Command failed. Retrying..."
        sleep 7
    fi
done

BILLING_SERVICE_URL=$(gcloud run services list \
--format='value(URL)' \
--filter="billing-service")

curl -X POST -H "Content-Type: application/json" \
-H "Authorization: Bearer $(gcloud auth print-identity-token)" \
$BILLING_SERVICE_URL -d '{"userid": "1234", "minBalance": 500}'

curl -X POST -H "Content-Type: application/json" \
-H "Authorization: Bearer $(gcloud auth print-identity-token)" \
$BILLING_SERVICE_URL -d '{"userid": "1234", "minBalance": 700}'
```

## Lab Completed🎉