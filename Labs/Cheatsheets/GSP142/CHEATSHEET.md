# **To be done using Google Cloud Shell**

**1. Create Bigtable instance**

**2. Create Kubernetes Engine cluster**

**3. Create ConfigMap**

**4. Create OpenTSDB tables in Bigtable**

**5. Deploy OpenTSDB**

**6. Create OpenTSDB services**

**7. Examining time-series data with OpenTSDB**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud config set compute/zone $ZONE

BIGTABLE_INSTANCE_ID=bt-opentsdb
AR_REPO=opentsdb-bt-repo
SERVER_IMAGE_NAME=opentsdb-server-bigtable
SERVER_IMAGE_TAG=2.4.1
GEN_IMAGE_NAME=opentsdb-timeseries-generate
GEN_IMAGE_TAG=0.1

git clone https://github.com/GoogleCloudPlatform/opentsdb-bigtable.git
cd opentsdb-bigtable

git clone https://github.com/GoogleCloudPlatform/opentsdb-bigtable.git

cd opentsdb-bigtable

gcloud bigtable instances create ${BIGTABLE_INSTANCE_ID} \
    --cluster-config=id=${BIGTABLE_INSTANCE_ID}-${ZONE},zone=${ZONE},nodes=1 \
    --display-name=OpenTSDB

gcloud container clusters create opentsdb-cluster \
--zone=$ZONE \
--machine-type e2-standard-4 \
--scopes "https://www.googleapis.com/auth/cloud-platform"

gcloud artifacts repositories create ${AR_REPO} \
    --repository-format=docker  \
    --location=${REGION} \
    --description="OpenTSDB on bigtable container images"

gcloud builds submit \
    --tag ${REGION}-docker.pkg.dev/${ID}/${AR_REPO}/${SERVER_IMAGE_NAME}:${SERVER_IMAGE_TAG} \
    build

cd generate-ts
./build-cloud.sh
cd ..

envsubst < configmaps/opentsdb-config.yaml.tpl | kubectl create -f -

envsubst < jobs/opentsdb-init.yaml.tpl | kubectl create -f -

kubectl describe jobs

sleep 60

OPENTSDB_INIT_POD=$(kubectl get pods --selector=job-name=opentsdb-init \
                    --output=jsonpath={.items..metadata.name})
kubectl logs $OPENTSDB_INIT_POD

envsubst < deployments/opentsdb-write.yaml.tpl | kubectl create -f  -

envsubst < deployments/opentsdb-read.yaml.tpl | kubectl create -f  -

kubectl get pods

kubectl create -f services/opentsdb-write.yaml

kubectl create -f services/opentsdb-read.yaml

kubectl get services

envsubst < deployments/generate.yaml.tpl | kubectl create -f -

kubectl create -f configmaps/grafana.yaml
kubectl create -f deployments/grafana.yaml

```
## Lab Completed🎉