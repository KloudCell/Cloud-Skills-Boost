# **To be done using Google Cloud Console and Cloud Shell**

**1. Create the blue server**

**2. Create the green server**

**3. Install Nginx and customize the welcome page**

**4. Create the tagged firewall rule**

**5. Create a test-vm**

**6. Create a Network-admin service account**

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

gcloud compute instances create blue \
--project=$ID \
--zone=$ZONE \
--tags=web-server,http-server \
--metadata=startup-script=sudo\ apt-get\ install\ nginx-light\ -y$'\n'sudo\ sed\ -i\ \"14c\\\<h1\>Welcome\ to\ the\ blue\ server\!\</h1\>\"\ /var/www/html/index.nginx-debian.html

gcloud compute instances create green \
--project=$ID \
--zone=$ZONE \
--metadata=startup-script=sudo\ apt-get\ install\ nginx-light\ -y$'\n'sudo\ sed\ -i\ \"14c\\\<h1\>Welcome\ to\ the\ green\ server\!\</h1\>\"\ /var/www/html/index.nginx-debian.html

gcloud compute firewall-rules create allow-http-web-server \
--project=$ID \
--network=default \
--target-tags=web-server \
--source-ranges=0.0.0.0/0 \
--action=ALLOW \
--rules=tcp:80,icmp

gcloud compute instances create test-vm \
--machine-type=e2-micro \
--subnet=default \
--zone=$ZONE

gcloud iam service-accounts create network-admin \
--display-name="Network-admin"
```
## Lab Completed🎉