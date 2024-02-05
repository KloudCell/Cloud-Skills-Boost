# **To be done using Google Cloud Console and Cloud Shell**

**1. Create a bucket using the GCP Console**

- Run below cmd & navigate to `Cloud Storage` and create a `Bucket`

```
echo "https://console.cloud.google.com/storage/create-bucket?project=$ID"
```

**2. Create a bucket using Cloud Shell**

**3. Upload a file to Storage bucket**

```
gsutil mb gs://$ID
touch kloudcell.txt
gsutil cp kloudcell.txt gs://$ID
```

## Lab Completed🎉

