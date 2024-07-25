# **To be done using Google Cloud Shell**

**1. Create a Cloud Storage bucket**

**2. Copy an object to a folder in the bucket (ada.jpg)**

**3. Make your object publicly accessible**

```bash
export ID=$(gcloud info --format='value(config.project)')

gsutil mb gs://$ID

wget -o ada.jpg https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Ada_Lovelace_portrait.jpg/800px-Ada_Lovelace_portrait.jpg
gsutil cp ./ada.jpg gs://$ID/image-folder/ada.jpg

gsutil acl ch -u AllUsers:R gs://$ID/image-folder/ada.jpg
```

## Lab Completed🎉