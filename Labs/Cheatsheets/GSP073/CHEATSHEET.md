# **To be execute in Google Cloud Shell**

**1. Create a bucket**

**2. Upload an object into the bucket (kitten.png)**

**3. Share a kitten.png object publicly**

```
export ID=$(gcloud info --format='value(config.project)')

gsutil mb gs://$ID

wget -O kitten.png https://cdn.qwiklabs.com/8tnHNHkj30vDqnzokQ%2FcKrxmOLoxgfaswd9nuZkEjd8%3D

gsutil cp kitten.png gs://$ID

gsutil iam ch allUsers:objectViewer gs://$ID
```
## Lab Completed🎉