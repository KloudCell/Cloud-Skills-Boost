# **To be done using Google Cloud Console and Shell**

**1. Deploy GKE cluster**

**2. Modify GKE clusters**

**3. Deploy a sample nginx workload**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

gcloud beta container --project "$ID" clusters create "standard-cluster-1" --zone $ZONE

gcloud container clusters resize standard-cluster-1 --num-nodes=4 --zone $ZONE -q

sleep 33

kubectl create deployment nginx-1 --image=nginx:latest
```

## Lab Completed🎉