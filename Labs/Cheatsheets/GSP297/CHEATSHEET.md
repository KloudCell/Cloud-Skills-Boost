# **To be done using Google Cloud Shell**

**1. Create a storage bucket**

**2. Set up Retention Policy**

**3. Lock the Retention Policy**

**4. Set up Temporary Hold**

**5. Create Event-based holds**

```bash
export BUCKET=$(gcloud config get-value project)
gsutil mb "gs://$BUCKET"
gsutil retention set 10s "gs://$BUCKET"
gsutil retention get "gs://$BUCKET"
gsutil cp gs://cloud-samples-data/storage/bucket-lock/dummy_transactions "gs://$BUCKET/"
gsutil ls -L "gs://$BUCKET/dummy_transactions"
echo y | gsutil retention lock "gs://$BUCKET/"

gsutil retention temp set "gs://$BUCKET/dummy_transactions"
gsutil rm "gs://$BUCKET/dummy_transactions"
gsutil retention temp release "gs://$BUCKET/dummy_transactions"

gsutil retention event-default set "gs://$BUCKET/"
gsutil cp gs://cloud-samples-data/storage/bucket-lock/dummy_loan "gs://$BUCKET/"
gsutil ls -L "gs://$BUCKET/dummy_loan"
gsutil retention event release "gs://$BUCKET/dummy_loan"
gsutil ls -L "gs://$BUCKET/dummy_loan"
```
## Lab Completed🎉