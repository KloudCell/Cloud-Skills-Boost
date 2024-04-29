# **To be done using Google Cloud Shell**

**1. Confirm that a Google Cloud Storage bucket exists that contains a file**

**2. Confirm that a compute instance has been created that has a remote startup script called install-web.sh configured**

**3. Confirm that a HTTP access firewall rule exists with tag that applies to that virtual machine**

**4. Connect to the server ip-address using HTTP and get a non-error response**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gsutil mb gs://$ID

gsutil cp gs://spls/gsp301/install-web.sh gs://$ID

gcloud compute instances create kloudcell \
  --zone=$ZONE \
  --tags=apache-server \
  --metadata=startup-script-url=gs://$ID/install-web.sh

gcloud compute firewall-rules create allow-traffic \
--target-tags apache-server \
--allow tcp:80
```
## Lab Completed🎉