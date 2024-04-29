# **To be done using Google Cloud Shell**

**1. Create a GKE cluster**

**2. Install Anthos Service Mesh**

**3. Configure sidecar injection**

**4. Deploy ResNet50**

**5. Create ConfigMap**

**6. Create TensorFlow Serving deployment for ResNet50 model**

**7. Configure Istio Ingress gateway**

**8. Deploy ResNet101 as a canary release**

**9. Configure weighted load balancing**

**10. Configure focused canary testing**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

cd
SRC_REPO=https://github.com/GoogleCloudPlatform/mlops-on-gcp
kpt pkg get $SRC_REPO/workshops/mlep-qwiklabs/tfserving-canary-gke tfserving-canary

CLUSTER_NAME=cluster-1
WORKLOAD_POOL=${ID}.svc.id.goog
MESH_ID="proj-${PROJECT_NUMBER}"

gcloud config set compute/zone ${ZONE}
gcloud beta container clusters create ${CLUSTER_NAME} \
    --machine-type=e2-standard-4 \
    --num-nodes=5 \
    --workload-pool=${WORKLOAD_POOL} \
    --logging=SYSTEM,WORKLOAD \
    --monitoring=SYSTEM \
    --subnetwork=default \
    --release-channel=stable \
    --labels mesh_id=${MESH_ID}

kubectl create clusterrolebinding cluster-admin-binding   --clusterrole=cluster-admin   --user=$(whoami)@qwiklabs.net

curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.15 > asmcli

chmod +x asmcli

./asmcli install \
  --project_id $ID \
  --cluster_name $CLUSTER_NAME \
  --cluster_location $ZONE \
  --fleet_id $ID \
  --output_dir ./asm_output \
  --enable_all \
  --option legacy-default-ingressgateway \
  --ca mesh_ca \
  --enable_gcp_components

GATEWAY_NS=istio-gateway
kubectl create namespace $GATEWAY_NS

REVISION=$(kubectl get deploy -n istio-system -l app=istiod -o \
jsonpath={.items[*].metadata.labels.'istio\.io\/rev'}'{"\n"}')

kubectl label namespace $GATEWAY_NS \
istio.io/rev=$REVISION --overwrite

cd ~/asm_output

kubectl apply -n $GATEWAY_NS \
  -f samples/gateways/istio-ingressgateway/autoscalingv2

kubectl label namespace default istio-injection- istio.io/rev=$REVISION --overwrite

MODEL_BUCKET=${ID}-bucket
gsutil mb gs://${MODEL_BUCKET}

gsutil cp -r gs://spls/gsp778/resnet_101 gs://${MODEL_BUCKET}
gsutil cp -r gs://spls/gsp778/resnet_50 gs://${MODEL_BUCKET}

gsutil uniformbucketlevelaccess set on gs://${MODEL_BUCKET}

gsutil iam ch allUsers:objectViewer gs://${MODEL_BUCKET}

cd ~/tfserving-canary

sed -i "s@\[YOUR_BUCKET\]@$MODEL_BUCKET@g" tf-serving/configmap-resnet50.yaml

kubectl apply -f tf-serving/configmap-resnet50.yaml

cat tf-serving/deployment-resnet50.yaml

kubectl apply -f tf-serving/deployment-resnet50.yaml

kubectl get deployments

kubectl apply -f tf-serving/service.yaml

kubectl apply -f tf-serving/gateway.yaml

kubectl apply -f tf-serving/virtualservice.yaml

INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')

GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

curl -d @payloads/request-body.json -X POST http://$GATEWAY_URL/v1/models/image_classifier:predict

kubectl apply -f tf-serving/destinationrule.yaml

kubectl apply -f tf-serving/virtualservice-weight-100.yaml

cd ~/tfserving-canary

sed -i "s@\[YOUR_BUCKET\]@$MODEL_BUCKET@g" tf-serving/configmap-resnet101.yaml

kubectl apply -f tf-serving/configmap-resnet101.yaml

kubectl apply -f tf-serving/deployment-resnet101.yaml

kubectl apply -f tf-serving/virtualservice-weight-70.yaml

kubectl apply -f tf-serving/virtualservice-focused-routing.yaml
```

## Lab Completed🎉