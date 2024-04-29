# **To be done using Google Cloud Shell**

**1. Create a Cloud Storage bucket**

**2. Make file publicly readable**

**3. Customer-supplied encryption keys (CSEK)**

**4. Enable lifecycle management**

**5. Enable versioning**

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gsutil mb -p $ID -c STANDARD -l $REGION -b on gs://$ID

gsutil uniformbucketlevelaccess set off gs://$ID

curl \
https://hadoop.apache.org/docs/current/\
hadoop-project-dist/hadoop-common/\
ClusterSetup.html > setup.html

cp setup.html setup2.html
cp setup.html setup3.html

gcloud storage cp setup.html gs://$ID/

gsutil acl get gs://$ID/setup.html  > acl.txt
cat acl.txt

gsutil acl set private gs://$ID/setup.html
gsutil acl get gs://$ID/setup.html  > acl2.txt
cat acl2.txt


gsutil acl ch -u AllUsers:R gs://$ID/setup.html
gsutil acl get gs://$ID/setup.html  > acl3.txt
cat acl3.txt

rm setup.html

gcloud storage cp gs://$ID/setup.html setup.html

CSEK_KEY=$(python3 -c 'import base64; import os; print(base64.encodebytes(os.urandom(32)).decode("utf-8").strip())')

echo "Generated CSEK Key: $CSEK_KEY"

gsutil config -n

sed -i "324c\encryption_key=$CSEK_KEY" .boto

gsutil cp setup2.html gs://$ID/
gsutil cp setup3.html gs://$ID/

rm setup*

gsutil cp gs://$ID/setup* ./

cat setup.html
cat setup2.html
cat setup3.html

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

gsutil lifecycle get gs://$ID

gsutil versioning get gs://$ID

gsutil versioning set on gs://$ID

gsutil versioning get gs://$ID

ls -al setup.html

sed -i '5,9d' setup.html

gcloud storage cp -v setup.html gs://$ID

sed -i '5,9d' setup.html

gcloud storage cp -v setup.html gs://$ID

gcloud storage ls -a gs://$ID/setup.html

VARIABLE=$(gcloud storage ls -a gs://$ID/setup.html | head -n 1 | awk '{print $1}')

export VERSION_NAME=$VARIABLE

gcloud storage cp $VERSION_NAME recovered.txt

mkdir firstlevel
mkdir ./firstlevel/secondlevel
cp setup.html firstlevel
cp setup.html firstlevel/secondlevel

gsutil rsync -r ./firstlevel gs://$ID/firstlevel

sleep 30

gcloud compute instances create crossproject \
    --zone $ZONE \
    --machine-type e2-medium \
    --boot-disk-size 10GB \
    --boot-disk-type pd-balanced \
    --image-family debian-11 \
    --image-project debian-cloud
```
<!--
cat << 'EOF' > change.sh
#!/bin/bash

current_project=$(gcloud config get-value project)
echo "Current project ID: $current_project"

IFS=$'\n' projects=($(gcloud projects list --format="value(projectId)"))

projects=(${projects[@]//$current_project})
projects=(${projects[@]//qwiklabs-resources})

if [ ${#projects[@]} -eq 1 ]; then
    project=${projects[0]}
    gcloud config set project "$project"
    echo "New project ID: $project"
else
    echo "Error: More than one project ID remains after excluding the current project and 'qwiklabs-resources'."
fi
EOF

. change.sh
-->

**6. Create the resources in the second project**

**7. Create and verify the resources in the first project**

- Click the project selector dropdown in the title bar and select `username_2`
- Open a new `Cloud Shell Window`

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gsutil mb -p $ID -c STANDARD -l $REGION -b on gs://$ID-2

gsutil uniformbucketlevelaccess set off gs://$ID-2

touch test.txt

gsutil cp test.txt gs://$ID-2

gcloud iam service-accounts create cross-project-storage --display-name "Cross-Project Storage Account"

gcloud projects add-iam-policy-binding $ID --member="serviceAccount:cross-project-storage@$ID.iam.gserviceaccount.com" --role="roles/storage.objectViewer"

gcloud projects add-iam-policy-binding $ID --member="serviceAccount:cross-project-storage@$ID.iam.gserviceaccount.com" --role="roles/storage.objectAdmin"

gcloud iam service-accounts keys create credentials.json --iam-account=cross-project-storage@$ID.iam.gserviceaccount.com
```

## Lab Completed🎉