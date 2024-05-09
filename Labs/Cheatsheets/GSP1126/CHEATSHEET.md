# **To be done using Google Cloud Shell**

**1. Initialize Google Cloud SDK**

**2. Create an instance with name as lab-1 in Project 1**

**3. Update the default zone**

**4. Create a configuration for Username 2 and name it as user2**

**5. Restricting Username 2 to roles/viewer in Project 2**

**6. Create a new role with permissions for the devops team**

**7. Check binding to roles/iam.serviceAccountUser**

**8. Bound Username 2 to devops role**

**9. Create an instance with name as lab-2 in Project 2**

**10. Check the created service account**

**11. Check the binding for the service account to roles/iam.serviceAccountUser**

**12. Check the binding for the service account to roles/compute.instanceAdmin**

**13. Check lab-3 has the service account attached**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

USER_NAME_1=$(gcloud info --format='value(config.account)')
USER_NAME_2=$(gcloud projects get-iam-policy $ID --format="json" | jq -r --arg USER_NAME_1 "$USER_NAME_1" '.bindings[] | select(.role == "roles/viewer") | .members[] | select(startswith("user:")) | select(. != "user:" + $USER_NAME_1) | sub("user:"; "")')

PROJECT_ID_1=$ID
PROJECT_ID_2=$(gcloud projects list --format="value(projectId)" --filter="projectId!=${ID} AND projectId!=qwiklabs-resources")

ZONE_1=${ZONE}
ZONE_2=$(gcloud compute zones list --filter="region:$REGION" --format="value(NAME)" | grep -v $ZONE_1 | head -n 1)

SA=devops@${PROJECT_ID_2}.iam.gserviceaccount.com

cat > start.sh <<EOF
ZONE_1=${ZONE_1}
ZONE_2=${ZONE_2}
EOF

cat > task.sh << EOF
gcloud config configurations activate user2
echo "export PROJECTID2=$PROJECT_ID_2" >> ~/.bashrc
. ~/.bashrc

gcloud config configurations activate default

sudo yum -y install epel-release
sudo yum -y install jq

echo "export USERID2=$USER_NAME_2" >> ~/.bashrc

. ~/.bashrc
gcloud projects add-iam-policy-binding $PROJECT_ID_2 \
--member user:$USER_NAME_2 \
 --role=roles/viewer

gcloud config configurations activate user2
gcloud config set project $PROJECT_ID_2
gcloud config configurations activate default

gcloud iam roles create devops --project $PROJECT_ID_2 \
--permissions "compute.instances.create,compute.instances.delete,compute.instances.start,compute.instances.stop,compute.instances.update,compute.disks.create,compute.subnetworks.use,compute.subnetworks.useExternalIp,compute.instances.setMetadata,compute.instances.setServiceAccount"
gcloud projects add-iam-policy-binding $PROJECT_ID_2 \
--member user:$USER_NAME_2 --role=roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding $PROJECT_ID_2 \
--member user:$USER_NAME_2 --role=projects/$PROJECT_ID_2/roles/devops

gcloud config configurations activate user2

gcloud compute instances create lab-2 --zone $ZONE_2

gcloud config configurations activate default

gcloud config set project $PROJECT_ID_2

gcloud iam service-accounts create devops --display-name devops

gcloud projects add-iam-policy-binding $PROJECT_ID_2 \
--member serviceAccount:$SA --role=roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding $PROJECT_ID_2 \
--member serviceAccount:$SA --role=roles/compute.instanceAdmin

gcloud compute instances create lab-3 --zone "$ZONE_2" \
--service-account $SA \
--scopes "https://www.googleapis.com/auth/compute"
EOF

cat > login.sh << EOF
gcloud auth login --no-launch-browser --quiet
. start.sh
gcloud compute instances create lab-1 --zone=$ZONE_1
gcloud config set compute/zone $ZONE_2
gcloud init --skip-diagnostics --no-launch-browser
. task.sh
EOF

gcloud compute scp start.sh task.sh login.sh centos-clean:~/ --zone "$ZONE" -q --project "$ID"
gcloud compute ssh --zone "$ZONE" "centos-clean" --project "$ID" -q
```
```
. login.sh
```
- Click on the link and authorize using `Username 1`
- Now you will get the `Pick configuration to use:` option from this choose `Create a new configuration`
- Enter configuration name type `user2`
- Now you will get `Choose the account you would like to use to perform operations for this configuration:` choose the number that correspond to `Log in with a new account`
- For `Do you want to continue (Y/n)?` press Enter  
- Now click on the link generated and authorize it using `Username 2`
- Now you will be asked to `Pick cloud project to use:` if you see `Project ID 1` then choose it otherwise choose option `Enter a project ID` and copy-paste the `Project ID 1`

## Lab Completed🎉