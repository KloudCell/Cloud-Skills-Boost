# **To be done using Google Cloud Shell**

**Create a virtual machine with gcloud**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud compute instances create gcelab2 --machine-type e2-medium --zone $ZONE
```
## Lab Completed🎉