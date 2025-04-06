# **To be done using Google Cloud Shell**

**1. Create a Cloud Storage bucket**

**2. Make file publicly readable**

**3. Customer-supplied encryption keys (CSEK)**

**4. Enable lifecycle management**

**5. Enable versioning**

**6. Create the resources in the second project**

**7. Create and verify the resources in the first project**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

ID_2=$(gcloud projects list --filter "qwiklabs-gcp" --format="value(PROJECT_ID)" | grep -v $ID)

gsutil mb -p $ID -c STANDARD -l $REGION -b on gs://$ID

gsutil uniformbucketlevelaccess set off gs://$ID

curl https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/ClusterSetup.html \
> setup.html

cp setup.html setup2.html
cp setup.html setup3.html

gcloud storage cp setup.html gs://$ID/

gsutil acl get gs://$ID/setup.html  > acl.txt

gsutil acl set private gs://$ID/setup.html
gsutil acl get gs://$ID/setup.html  > acl2.txt

gsutil acl ch -u AllUsers:R gs://$ID/setup.html
gsutil acl get gs://$ID/setup.html  > acl3.txt

CSEK_KEY=$(python3 -c 'import base64; import os; print(base64.encodebytes(os.urandom(32)).decode("utf-8").strip())')

echo "Generated CSEK Key: $CSEK_KEY"

gsutil config -n

sed -i "324c\encryption_key=$CSEK_KEY" .boto

gsutil cp setup2.html gs://$ID/
gsutil cp setup3.html gs://$ID/

sed -i "324c\#encryption_key=$CSEK_KEY" .boto

sed -i "331c\decryption_key1=$CSEK_KEY" .boto

CSEK_KEY=$(python3 -c 'import base64; import os; print(base64.encodebytes(os.urandom(32)).decode("utf-8").strip())')

echo "Generated CSEK Key: $CSEK_KEY"

sed -i "324c\encryption_key=$CSEK_KEY" .boto

gsutil rewrite -k gs://$ID/setup2.html

sed -i "331c\#decryption_key1=$CSEK_KEY" .boto

gsutil cp gs://$ID/setup2.html recover2.html

gsutil cp gs://$ID/setup3.html recover3.html

gsutil lifecycle get gs://$ID

cat << 'EOF' > life.json
{
  "rule":
  [
    {
      "action": {"type": "Delete"},
      "condition": {"age": 31}
    }
  ]
}
EOF

gsutil lifecycle set life.json gs://$ID

gsutil versioning set on gs://$ID

gsutil versioning get gs://$ID

gcloud compute instances create crossproject \
    --zone $ZONE \
    --machine-type e2-medium \
    --boot-disk-size 10GB \
    --boot-disk-type pd-balanced \
    --image-family debian-11 \
    --image-project debian-cloud

gsutil mb -p $ID_2 -c STANDARD -l $REGION -b on gs://$ID_2

gsutil uniformbucketlevelaccess set off gs://$ID_2

touch kloudcell.txt

gsutil cp kloudcell.txt gs://$ID_2

gcloud iam service-accounts create cross-project-storage \
--display-name "Cross-Project Storage Account" \
--project=$ID_2

gcloud projects add-iam-policy-binding $ID_2 \
--member="serviceAccount:cross-project-storage@$ID_2.iam.gserviceaccount.com" \
--role="roles/storage.objectViewer" \
--project=$ID_2

gcloud projects add-iam-policy-binding $ID_2 \
--member="serviceAccount:cross-project-storage@$ID_2.iam.gserviceaccount.com" \
--role="roles/storage.objectAdmin"
```

## Lab Completed🎉