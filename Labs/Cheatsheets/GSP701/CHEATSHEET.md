# **To be done using Google Cloud Shell & Web Preview**

**1. Check Firestore Database Deployment**

- **1st Terminal**
```
git clone https://github.com/GoogleCloudPlatform/DIY-Tools.git
gcloud firestore import gs://$GOOGLE_CLOUD_PROJECT-firestore/prd-back
cd ~/DIY-Tools/gcp-data-drive/cmd/webserver
go build -mod=readonly -v -o gcp-data-drive
./gcp-data-drive
```

- Don't run `2nd Terminal` commands until you see `Listening on port 8080` in `Terminal 1`

**2. Check Cloud Shell application Deployment**

- **2nd Terminal**
- Run below CMD & open the link generated from it
```
echo "https://8080-$WEB_HOST/bq/$GOOGLE_CLOUD_PROJECT/publicviews/ca_zip_codes?authuser=0&environment_name=default"
```
- **2nd Terminal**

**3. Check App Engine Application Deployments**

**4. Check App Engine application Deployment**

```
cd ~/DIY-Tools/gcp-data-drive/cmd/webserver
gcloud app deploy app.yaml --project $GOOGLE_CLOUD_PROJECT -q
export TARGET_URL=https://$(gcloud app describe --format="value(defaultHostname)")
curl $TARGET_URL/fs/$GOOGLE_CLOUD_PROJECT/symbols/product/symbol
```

## Lab Completed🎉