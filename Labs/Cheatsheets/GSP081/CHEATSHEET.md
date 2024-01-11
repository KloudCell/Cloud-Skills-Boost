# **To be execute in Google Cloud Shell**

**1. Deploy the function.**

**2. Test the function**

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud services enable run.googleapis.com

cat > index.js <<EOF
/**
 * Responds to any HTTP request.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */
exports.GCFunction = (req, res) => {
    let message = req.query.message || req.body.message || 'Hello KloudCell';
    res.status(200).send(message);
  };
EOF

cat > package.json <<EOF
{
    "name": "sample-http",
    "version": "0.0.1"
  }
EOF

gsutil mb -p $ID gs://$ID

export PROJECT_NUMBER=$(gcloud projects describe $ID --format="json(projectNumber)" --quiet | jq -r '.projectNumber')

SERVICE_ACCOUNT="service-$PROJECT_NUMBER@gcf-admin-robot.iam.gserviceaccount.com"

IAM_POLICY=$(gcloud projects get-iam-policy $ID --format=json)

gcloud projects add-iam-policy-binding $ID \
    --member=serviceAccount:$SERVICE_ACCOUNT \
    --role=roles/artifactregistry.reader

while [[ "$IAM_POLICY" == *"$SERVICE_ACCOUNT"* || "$IAM_POLICY" == *"roles/artifactregistry.reader"* ]]; do
  echo "IAM binding does not exist for service account: $SERVICE_ACCOUNT with role roles/artifactregistry.reader"
  echo "Checking again in 33 seconds..."
  sleep 33
done

YELLOW='\033[1;33m'
NC='\033[0m' # No Color

cat<<EOF>check.sh
printf "${YELLOW}Checking${NC}"

# Dot animation
for i in {1..3}; do
  printf "${YELLOW}.${NC}"
  sleep 1
done

printf "\r${YELLOW}Checked!${NC}                                    "
sleep 3
echo -e "\n${YELLOW}IAM binding exists for service account: $SERVICE_ACCOUNT with role roles/artifactregistry.reader${NC}"
EOF

. check.sh

while true; do
  if gcloud functions deploy GCFunction \
    --region=$REGION \
    --gen2 \
    --trigger-http \
    --runtime=nodejs20 \
    --allow-unauthenticated \
    --max-instances=5; then
    echo "Function deployed successfully"
    break
  else
    echo "Deployment failed, retrying in 30 seconds..."
    sleep 30
  fi
done


DATA=$(printf 'Hello KloudCell' | base64) && gcloud functions call GCFunction --region=$REGION --data '{"data":"'$DATA'"}'
```

## Lab Completed🎉