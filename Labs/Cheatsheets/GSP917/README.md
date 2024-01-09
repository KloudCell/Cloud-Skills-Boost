# **To be done using Google Cloud Console and Shell**

**1. Enable Google Cloud services**

**2. Create Vertex AI custom service account for Vertex Tensorboard integration**

**3. Launch Vertex AI Workbench notebook**

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

gcloud services enable \
  compute.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  notebooks.googleapis.com \
  aiplatform.googleapis.com \
  bigquery.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  container.googleapis.com

SERVICE_ACCOUNT_ID=vertex-custom-training-sa
gcloud iam service-accounts create $SERVICE_ACCOUNT_ID  \
    --description="A custom service account for Vertex custom training with Tensorboard" \
    --display-name="Vertex AI Custom Training"

PROJECT_ID=$(gcloud config get-value core/project)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com \
    --role="roles/bigquery.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$SERVICE_ACCOUNT_ID@$PROJECT_ID.iam.gserviceaccount.com \
    --role="roles/aiplatform.user"

gcloud notebooks instances create kloudcell \
    --location=$ZONE \
    --vm-image-project=deeplearning-platform-release \
    --vm-image-family=tf2-ent-latest-cpu \
    --machine-type=e2-standard-2

sleep 77
```

**4. Clone the lab repository**

- Click on the link generated from below cmd
```
echo 'https://'$(gcloud notebooks instances describe kloudcell --location=$ZONE --format="value(proxyUri)")'/lab'
```
-  Open Terminal in JupyterLab and paste the below link

```
git clone --depth=1 https://github.com/GoogleCloudPlatform/training-data-analyst
```