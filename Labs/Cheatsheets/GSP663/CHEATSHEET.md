# **To be done using Google Cloud Shell**

**1. Create a GKE cluster**

**2. Create Docker container with Cloud Build**

**3. Deploy container to GKE**

**4. Expose GKE Deployment**

**5. Scale GKE deployment**

**6. Make changes to the website**

**7. Update website with zero downtime**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud config set compute/zone $ZONE
gcloud services enable container.googleapis.com
gcloud container clusters create fancy-cluster --num-nodes 3
cd ~
git clone https://github.com/googlecodelabs/monolith-to-microservices.git
cd ~/monolith-to-microservices
./setup.sh
nvm install --lts
cd ~/monolith-to-microservices/monolith
timeout 30 npm start

gcloud services enable cloudbuild.googleapis.com
cd ~/monolith-to-microservices/monolith
gcloud builds submit --tag gcr.io/${ID}/monolith:1.0.0 .

kubectl create deployment monolith --image=gcr.io/${ID}/monolith:1.0.0

kubectl expose deployment monolith --type=LoadBalancer --port 80 --target-port 8080
sleep 30

kubectl scale deployment monolith --replicas=3
sleep 30

cd ~/monolith-to-microservices/react-app/src/pages/Home
mv index.js.new index.js

cd ~/monolith-to-microservices/react-app
npm run build:monolith

cd ~/monolith-to-microservices/monolith
gcloud builds submit --tag gcr.io/${ID}/monolith:2.0.0 .

kubectl set image deployment/monolith monolith=gcr.io/${ID}/monolith:2.0.0

timeout 60 npm start
```

## Lab Completed🎉