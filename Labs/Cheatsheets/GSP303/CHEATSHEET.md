# **To be done using Google Cloud Shell**

**1. A new non-default VPC has been created**

**2. The new VPC contains a new non-default subnet within it**

**3. A firewall rule exists that allows TCP port 3389 traffic ( for RDP )**

**4. A Windows compute instance called vm-securehost exists that does not have a public ip-address**

**5. A Windows compute instance called vm-bastionhost exists that has a public ip-address to which the TCP port 3389 firewall rule applies.**

**6. The vm-securehost is running Microsoft IIS web server software.**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud compute networks create securenetwork \
--project=$ID \
--subnet-mode=custom \
--mtu=1460 \
--bgp-routing-mode=regional

gcloud compute networks subnets create securenetwork-subnet \
--project=$ID \
--region=$REGION \
--range=10.0.0.0/24 \
--stack-type=IPV4_ONLY \
--network=securenetwork

gcloud compute firewall-rules create allow-rdp \
--project=$ID \
--network=securenetwork \
--action=ALLOW \
--rules=tcp:3389 \
--source-ranges=0.0.0.0/0 \
--target-tags allow-rdp-traffic

cat<< 'EOF' > startup.ps1
# startup.ps1
Import-Module ServerManager
Add-WindowsFeature Web-Server
EOF

gcloud compute instances create vm-securehost \
--project=$ID \
--zone=$ZONE \
--machine-type=e2-standard-2 \
--network-interface=subnet=securenetwork-subnet,no-address \
--network-interface=subnet=default,no-address \
--tags=allow-rdp-traffic \
--image-project=windows-cloud \
--image-family=windows-2016 \
--metadata-from-file windows-startup-script-ps1=startup.ps1

gcloud compute instances create vm-bastionhost \
--project=$ID \
--zone=$ZONE \
--machine-type=e2-standard-2 \
--network-interface=subnet=securenetwork-subnet \
--network-interface=subnet=default,no-address \
--tags=allow-rdp-traffic \
--image-project=windows-cloud \
--image-family=windows-2016

sleep 420

echo -e "\e[38;5;208mWeb Server (IIS) Installed\e[0m"
```
## Lab Completed🎉