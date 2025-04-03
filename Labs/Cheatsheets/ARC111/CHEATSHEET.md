# **To be done using Google Cloud Shell**

**Task 1, Task 2, Task 3**

- Check `Form ID`number from [Challenge scenario](https://www.cloudskillsboost.google/focuses/63246?parent=catalog#step4)

```bash
export ID="$(gcloud config get-value project)"
touch sample.txt	

form_1() {
gsutil mb -p $ID gs://$ID-bucket

gsutil retention set 30s gs://$ID-gcs-bucket

gsutil cp sample.txt gs://$ID-bucket-ops/
}

form_2() {
gsutil mb -c nearline gs://$ID-bucket

gcloud alpha storage buckets update gs://$ID-gcs-bucket --no-uniform-bucket-level-access

gsutil acl ch -u $USER_EMAIL:OWNER gs://$ID-gcs-bucket

gsutil rm gs://$ID-gcs-bucket/sample.txt

gsutil cp sample.txt gs://$ID-gcs-bucket

gsutil acl ch -u allUsers:R gs://$ID-gcs-bucket/sample.txt

gcloud storage buckets update gs://$ID-bucket-ops --update-labels=key=value
}

form_3() {
gsutil mb -c coldline gs://$ID-bucket

echo "This is an example of editing the file content for cloud storage object" | gsutil cp - gs://$ID-gcs-bucket/sample.txt

gsutil defstorageclass set ARCHIVE gs://$ID-bucket-ops
}

read -p "Enter your Form number (1, 2, or 3): " form_num

case $form_num in
    1) form_1 ;;
    2) form_2 ;;
    3) form_3 ;;
    *) echo "Invalid form number. Please enter 1, 2, or 3." ;;
esac
```

## Lab Completed🎉