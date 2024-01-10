# **To be execute in Google Cloud Shell**

**1. Create a bucket and upload a sample file**

**2. Remove project access**

**3. Add Storage permissions**

```
export ID=$(gcloud info --format='value(config.project)')

echo " " > sample.txt

gsutil mb -p $ID gs://$ID
gsutil cp sample.txt gs://$ID/

echo -e "\033[1;33mPaste Username 2 here> \033[0m"
read user2

gcloud projects remove-iam-policy-binding $ID \
    --member=user:$user2 --role=roles/viewer 

gcloud projects add-iam-policy-binding $ID \
    --member=user:$user2 --role=roles/storage.objectViewer
```

## Lab Completed🎉