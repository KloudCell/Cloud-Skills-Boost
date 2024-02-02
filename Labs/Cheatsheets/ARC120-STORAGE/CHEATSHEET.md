# **To be execute in Google Cloud Shell**

**Fix this ticket**

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

BUCKET=$ID-bucket

gsutil mb  -l $REGION gs://$BUCKET
```

## Lab Completed🎉