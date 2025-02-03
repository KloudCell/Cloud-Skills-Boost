# **To be execute in Google Cloud Shell**

**1. Create an API Key**

**2. Upload an image to your bucket**

**3. Upload an image for Face Detection to your bucket**

**4. Upload an image for Landmark Annotation to your bucket**

```bash
export API_KEY=$(gcloud beta services api-keys create --display-name='KloudCell' 2>&1 >/dev/null | grep -o 'keyString":"[^"]*' | cut -d'"' -f3)

export BUCKET=$(gcloud info --format='value(config.project)')-bucket

gsutil mb gs://$BUCKET

wget -O donuts.png https://cdn.qwiklabs.com/V4PmEUI7yXdKpytLNRqwV%2ByGHqym%2BfhdktVi8nj4pPs%3D 2> /dev/null

gsutil cp donuts.png gs://$BUCKET

gsutil acl ch -u AllUsers:R gs://$BUCKET/donuts.png

wget -O selfie.png https://cdn.qwiklabs.com/5%2FxwpTRxehGuIRhCz3exglbWOzueKIPikyYj0Rx82L0%3D 2> /dev/null

gsutil cp selfie.png gs://$BUCKET

gsutil acl ch -u AllUsers:R gs://$BUCKET/selfie.png

wget -O city.png https://cdn.qwiklabs.com/9nhXkPugaX2KuBtzDMgr24M%2BiaqXaorWzzhFHZ0XzX8%3D 2> /dev/null

gsutil cp city.png gs://$BUCKET

gsutil acl ch -u AllUsers:R gs://$BUCKET/city.png
```

## Lab Completed🎉