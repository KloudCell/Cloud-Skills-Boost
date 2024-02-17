# **To be done using Google Cloud Shell & Cloud Console**

**1. Create a Cloud Storage Bucket**

```
export ID=$(gcloud info --format='value(config.project)')
export BUCKET=$ID-vcm

gsutil mb -p $ID -c standard -l us gs://$BUCKET/
```
**2. Create a dataset**

```
gsutil -m cp -r gs://spls/gsp223/images/* gs://${BUCKET}
gsutil cp gs://spls/gsp223/data.csv .
sed -i -e "s/placeholder/${BUCKET}/g" ./data.csv
gsutil cp ./data.csv gs://${BUCKET}

echo -e "\n\e[31mNavigate to this link to create dataset:\e[0m"
echo -e "\nhttps://console.cloud.google.com/vertex-ai/datasets/create?project=$ID\n"
```

- Set Dataset name to :
```
clouds
```
- Select `Image classification (Single-label)`
- Click Create
- Choose `Select import files from Cloud Storage` 
- Now run below CMD in `Cloud Shell` 
```
echo "$BUCKET/data.csv"
```
- Copy the generated text & paste it to the field below `Select import files from Cloud Storage`
- Click `Continue` and wait for 2-5 minutes for process to be done
<!--
pip install google-cloud-aiplatform

cat << 'EOF' > classification.py
from google.cloud import aiplatform

# Define your display name and Google Cloud Storage source
display_name = "clouds"
gcs_source = "gs://path-to-your-data-in-gcs/data.csv"

# Initialize the SDK
aiplatform.init(project="your-project-id", location="us-central1")

# Create the dataset
dataset = aiplatform.ImageDataset.create(
    display_name=display_name,
    gcs_source=gcs_source,
    import_schema_uri=aiplatform.schema.dataset.ioformat.image.single_label_classification
)

print(dataset.resource_name)
EOF

sed -i "s/path-to-your-data-in-gcs/$BUCKET/g" classification.py
sed -i "s/your-project-id/$ID/g" classification.py

python3 a.py
-->

## Lab Completed🎉