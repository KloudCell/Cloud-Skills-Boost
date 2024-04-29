# **To be done using VS Code Terminal**

**1. Create a Kubernetes Cluster with Binary Authorization**

**2. Update Binary Authorization Policy to add Disallow all images rule at project level and allow at cluster level**

**3. Update cluster specific policy to Disallow all images**

**4. Create a Nginx pod to verify cluster admission rule is applied for disallow all images (denies to create)**

**5. Update BA policy to denying images except from whitelisted container registries (your project container registry)**

**6. Update BA policy to modify cluster specific rule to allow only images that have been approved by attestors**

**7. Tear Down (delete cluster)**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud services enable compute.googleapis.com \
container.googleapis.com \
containerregistry.googleapis.com \
containeranalysis.googleapis.com \
binaryauthorization.googleapis.com 

ATTESTOR="manually-verified"
ATTESTOR_NAME="Manual Attestor"
ATTESTOR_EMAIL="$(gcloud config get-value core/account)"
NOTE_ID="Human-Attestor-Note"
NOTE_DESC="Human Attestation Note Demo"
NOTE_PAYLOAD_PATH="note_payload.json"
IAM_REQUEST_JSON="iam_request.json"
IMAGE_PATH=$(echo "gcr.io/${ID}/nginx*")
PGP_PUB_KEY="generated-key.pgp"
GENERATED_PAYLOAD="generated_payload.json"
GENERATED_SIGNATURE="generated_signature.pgp"

sleep 33

gsutil -m cp -r gs://spls/gke-binary-auth/* .

cd gke-binary-auth-demo

gcloud config set compute/region $REGION    
gcloud config set compute/zone $ZONE

chmod +x create.sh
chmod +x delete.sh
chmod 777 validate.sh

sed -i 's/validMasterVersions\[0\]/defaultClusterVersion/g' ./create.sh

./create.sh -c my-cluster-1

./validate.sh -c my-cluster-1

cat <<'EOF'> policy.yaml 
defaultAdmissionRule:
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
  evaluationMode: ALWAYS_DENY
globalPolicyEvaluationMode: ENABLE
clusterAdmissionRules:
  ZONE.my-cluster-1:
    evaluationMode: ALWAYS_ALLOW
    enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
name: projects/PROJECT_ID/policy
EOF

sed -i "s/PROJECT_ID/${ID}/g" policy.yaml
sed -i "s/ZONE/${ZONE}/g" policy.yaml

gcloud beta container binauthz policy import policy.yaml

docker pull gcr.io/google-containers/nginx:latest

gcloud auth configure-docker --quiet

docker tag gcr.io/google-containers/nginx "gcr.io/${ID}/nginx:latest"
docker push "gcr.io/${ID}/nginx:latest"

gcloud container images list-tags "gcr.io/${ID}/nginx"

cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: "gcr.io/${ID}/nginx:latest"
    ports:
    - containerPort: 80
EOF

kubectl get pods

kubectl delete pod nginx

cat <<'EOF'> policy.yaml 
defaultAdmissionRule:
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
  evaluationMode: ALWAYS_DENY
globalPolicyEvaluationMode: ENABLE
clusterAdmissionRules:
  ZONE.my-cluster-1:
    evaluationMode: ALWAYS_DENY
    enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
name: projects/PROJECT_ID/policy
EOF

sed -i "s/PROJECT_ID/${ID}/g" policy.yaml
sed -i "s/ZONE/${ZONE}/g" policy.yaml

gcloud beta container binauthz policy import policy.yaml

cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: "gcr.io/${ID}/nginx:latest"
    ports:
    - containerPort: 80
EOF

gcloud logging read "resource.type='k8s_cluster'  AND protoPayload.response.reason='VIOLATES_POLICY'" --project=$ID --format=json

cat <<'EOF'> policy.yaml 
defaultAdmissionRule:
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
  evaluationMode: ALWAYS_DENY
globalPolicyEvaluationMode: ENABLE
clusterAdmissionRules:
  ZONE.my-cluster-1:
    evaluationMode: ALWAYS_DENY
    enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
admissionWhitelistPatterns:
- namePattern: "gcr.io/PROJECT_ID/nginx*"
name: projects/PROJECT_ID/policy
EOF

sed -i "s/PROJECT_ID/${ID}/g" policy.yaml
sed -i "s/ZONE/${ZONE}/g" policy.yaml

gcloud beta container binauthz policy import policy.yaml

cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: "gcr.io/${ID}/nginx:latest"
    ports:
    - containerPort: 80
EOF

kubectl delete pod nginx

cat > ${NOTE_PAYLOAD_PATH} << EOF
{
  "name": "projects/${ID}/notes/${NOTE_ID}",
  "attestation_authority": {
    "hint": {
      "human_readable_name": "${NOTE_DESC}"
    }
  }
}
EOF

curl -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $(gcloud auth print-access-token)"  \
    --data-binary @${NOTE_PAYLOAD_PATH}  \
    "https://containeranalysis.googleapis.com/v1beta1/projects/${ID}/notes/?noteId=${NOTE_ID}"

curl -H "Authorization: Bearer $(gcloud auth print-access-token)"  \
    "https://containeranalysis.googleapis.com/v1beta1/projects/${ID}/notes/${NOTE_ID}"

sudo apt-get install rng-tools -y
sudo rngd -r /dev/urandom -y

gcloud --project="${ID}" \
    beta container binauthz attestors create "${ATTESTOR}" \
    --attestation-authority-note="${NOTE_ID}" \
    --attestation-authority-note-project="${ID}"

gcloud --project="${ID}" \
    beta container binauthz attestors public-keys add \
    --attestor="${ATTESTOR}" \
    --pgp-public-key-file="${PGP_PUB_KEY}"

gcloud --project="${ID}" \
    beta container binauthz attestors list

PGP_FINGERPRINT="$(gpg --list-keys ${ATTESTOR_EMAIL} | head -2 | tail -1 | awk '{print $1}')"
IMAGE_PATH="gcr.io/${ID}/nginx"
IMAGE_DIGEST="$(gcloud container images list-tags --format='get(digest)' $IMAGE_PATH | head -1)"

gcloud beta container binauthz create-signature-payload \
    --artifact-url="${IMAGE_PATH}@${IMAGE_DIGEST}" > ${GENERATED_PAYLOAD}

gpg --local-user "${ATTESTOR_EMAIL}" \
    --armor \
    --output ${GENERATED_SIGNATURE} \
    --sign ${GENERATED_PAYLOAD}

gcloud beta container binauthz attestations create \
    --artifact-url="${IMAGE_PATH}@${IMAGE_DIGEST}" \
    --attestor="projects/${ID}/attestors/${ATTESTOR}" \
    --signature-file=${GENERATED_SIGNATURE} \
    --public-key-id="${PGP_FINGERPRINT}"

gcloud beta container binauthz attestations list \
    --attestor="projects/${ID}/attestors/${ATTESTOR}"

IMAGE_DIGEST="$(gcloud container images list-tags --format='get(digest)' $IMAGE_PATH | head -1)"

cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: "${IMAGE_PATH}@${IMAGE_DIGEST}"
    ports:
    - containerPort: 80
EOF

gcloud container binauthz policy export > /tmp/policy.yaml

awk -v id=$ID '/evaluationMode: ALWAYS_DENY/ && !x {print "    evaluationMode: REQUIRE_ATTESTATION\n    requireAttestationsBy:\n    - projects/"id"/attestors/manually-verified"; x=1; next} 1' /tmp/policy.yaml > temp && mv temp /tmp/policy.yaml

gcloud container binauthz policy import /tmp/policy.yaml

cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx-alpha
  annotations:
    alpha.image-policy.k8s.io/break-glass: "true"
spec:
  containers:
  - name: nginx
    image: "nginx:latest"
    ports:
    - containerPort: 80
EOF

./delete.sh -c my-cluster-1
```

## Lab Completed🎉