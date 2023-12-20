# **To be execute in Google Cloud Shell**

**1. Create a Cloud Storage Bucket**

**2. Make a second Cloud Storage bucket**

**3. Upload Files to Your Cloud Storage Bucket (demo-image1.png and demo-image2.png)**

**4. Copy files between Cloud Storage buckets (demo-image1-copy.png)**

    export ID=$(gcloud config list --format 'value(core.project)')
    gsutil mb gs://$ID
    gsutil mb gs://$ID-2


    wget -O demo-image1.png https://cdn.qwiklabs.com/E4%2BSx10I0HBeOFPB15BFPzf9%2F%2FOK%2Btf7S0Mbn6aQ8fw%3D
    wget -O demo-image2.png https://cdn.qwiklabs.com/Hr8ohUSBSeAiMUJe1J998ydGcTu%2FrF4BUjZ2J%2BbiKps%3D

    gsutil cp demo-image1.png gs://$ID
    gsutil cp demo-image2.png gs://$ID

    gsutil cp gs://$ID/demo-image1.png gs://$ID-2/demo-image1-copy.png