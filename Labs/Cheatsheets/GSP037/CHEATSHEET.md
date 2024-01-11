# **To be execute in Google Cloud Shell**

**1. Create an API Key**

**2. Upload an image to your bucket**

**3. Upload an image for Face Detection to your bucket**

**4. Upload an image for Landmark Annotation to your bucket**

```

gcloud beta services api-keys create --display-name="API key 1"

export ID=$(gcloud info --format='value(config.project)')-bucket

gsutil mb gs://$ID

wget -o donuts.png https://cdn.qwiklabs.com/V4PmEUI7yXdKpytLNRqwV%2ByGHqym%2BfhdktVi8nj4pPs%3D

gsutil cp donuts.png gs://$ID

gsutil acl ch -u AllUsers:R gs://$ID/donuts.png

wget -o selfie.png https://cdn.qwiklabs.com/5%2FxwpTRxehGuIRhCz3exglbWOzueKIPikyYj0Rx82L0%3D

gsutil cp selfie.png gs://$ID

gsutil acl ch -u AllUsers:R gs://$ID/selfie.png

wget -o city.png https://cdn.qwiklabs.com/9nhXkPugaX2KuBtzDMgr24M%2BiaqXaorWzzhFHZ0XzX8%3D

gsutil cp city.png gs://$ID

gsutil acl ch -u AllUsers:R gs://$ID/city.png
```

## Lab Completed🎉