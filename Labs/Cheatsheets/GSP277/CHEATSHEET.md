# **To be execute in Google Cloud Shell**

**1. Create a Cloud Storage bucket.**

**2. Upload an image in a storage bucket (demo-image.jpg).**

**3. Make the uploaded image publicly accessible.**

    export ID=$(gcloud config list --format 'value(core.project)')

    gsutil mb gs://$ID-bucket

    wget -O demo-image.jpg https://cdn.qwiklabs.com/3hpf8ZMmvpav2QvPqQCY1Zl1O%2B%2F8rrass6yjAPki3Dc%3D
    gsutil cp demo-image.jpg gs://$ID-bucket

    gsutil acl ch -u AllUsers:R gs://$ID-bucket/demo-image.jpg

