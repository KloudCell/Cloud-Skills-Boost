# **To be done using Google Cloud Shell**

**1. Create two Cloud Storage Buckets**

**2. Upload image file to your Cloud Storage Bucket**

**3. Copy a file to another bucket**

**4. Make your object(file) publicly accessible**

**5. Delete file and Cloud Storage bucket (Bucket 1)**

```bash
export ID=$(gcloud info --format='value(config.project)')
export AUTH_ACCESS=$(gcloud auth print-access-token)

cat > bucket_1.json <<EOF
{  
   "name": "$ID-bucket-1",
   "location": "us",
   "storageClass": "multi_regional"
}
EOF

wget -O world.jpg https://cdn.qwiklabs.com/amN7kZDhflOmMUaM3tiFSjyw5yfXIqOxtrpslYJS2Kg%3D

curl -X POST -H "Authorization: Bearer ${AUTH_ACCESS}" \
-H "Content-Type: application/json" \
--data-binary @bucket_1.json "https://storage.googleapis.com/storage/v1/b?project=$ID"

cat > bucket_2.json <<EOF
{  
   "name": "$ID-bucket-2",
   "location": "us",
   "storageClass": "multi_regional"
}
EOF

curl -X POST -H "Authorization: Bearer ${AUTH_ACCESS}" \
-H "Content-Type: application/json" \
--data-binary @bucket_2.json "https://storage.googleapis.com/storage/v1/b?project=$ID"

cat > bucket_3.json <<EOF
{  
   "name": "$ID-bucket-3",
   "location": "us",
   "storageClass": "multi_regional"
}
EOF

curl -X POST -H "Authorization: Bearer ${AUTH_ACCESS}" \
-H "Content-Type: application/json" \
--data-binary @bucket_3.json "https://storage.googleapis.com/storage/v1/b?project=$ID"

curl -X POST -H "Authorization: Bearer ${AUTH_ACCESS}" \
-H "Content-Type: image/jpeg" \
--data-binary @world.jpg "https://storage.googleapis.com/upload/storage/v1/b/$ID-bucket-1/o?uploadType=media&name=world.jpg"

curl -X POST -H "Authorization: Bearer ${AUTH_ACCESS}" \
-H "Content-Type: application/json" \
--data '{"destination": "$ID-bucket-2"}' "https://storage.googleapis.com/storage/v1/b/$ID-bucket-1/o/world.jpg/copyTo/b/$ID-bucket-2/o/world.jpg"

cat > public_access.json <<EOF
{
  "entity": "allUsers",
  "role": "READER"
}
EOF

curl -X POST --data-binary @public_access.json \
-H "Authorization: Bearer ${AUTH_ACCESS}" \
-H "Content-Type: application/json" "https://storage.googleapis.com/storage/v1/b/$ID-bucket-1/o/world.jpg/acl"

curl -X DELETE \
-H "Authorization: Bearer ${AUTH_ACCESS}" "https://storage.googleapis.com/storage/v1/b/$ID-bucket-1/o/world.jpg"

curl -X DELETE -H "Authorization: Bearer ${AUTH_ACCESS}" "https://storage.googleapis.com/storage/v1/b/$ID-bucket-1"
```
## Lab Completed🎉