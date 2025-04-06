# To be done using Google Cloud Shell

**1. Create Artifact Registry repository**

**2. Create an Attestor**

**3. Add a KMS key**

**4. Create a GKE cluster and update the policies**

**5. Add a signing step**

**6. Deploy a signed image**

**7. Deploy an unsigned image**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

gcloud services enable \
  cloudkms.googleapis.com \
  cloudbuild.googleapis.com \
  container.googleapis.com \
  containerregistry.googleapis.com \
  artifactregistry.googleapis.com \
  containerscanning.googleapis.com \
  ondemandscanning.googleapis.com \
  binaryauthorization.googleapis.com 

gcloud artifacts repositories create artifact-scanning-repo \
  --repository-format=docker \
  --location=$REGION \
  --description="Docker repository"

gcloud auth configure-docker $REGION-docker.pkg.dev

mkdir vuln-scan && cd vuln-scan

cat > ./Dockerfile << EOF
FROM python:3.8-alpine  

WORKDIR /app
COPY . ./

RUN pip3 install Flask==2.1.0
RUN pip3 install gunicorn==20.1.0
RUN pip3 install Werkzeug==2.2.2

CMD exec gunicorn --bind :\$PORT --workers 1 --threads 8 main:app
EOF

cat > ./main.py << EOF
import os
from flask import Flask

app = Flask(__name__)
@app.route("/")
def hello_world():
    name = os.environ.get("NAME", "Worlds")
    return "Hello {}!".format(name)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
EOF

gcloud builds submit . -t $REGION-docker.pkg.dev/${ID}/artifact-scanning-repo/sample-image

cat > ./vulnz_note.json << EOF
{
  "attestation": {
    "hint": {
      "human_readable_name": "Container Vulnerabilities attestation authority"
    }
  }
}
EOF

NOTE_ID=vulnz_note
curl -vvv -X POST \
    -H "Content-Type: application/json"  \
    -H "Authorization: Bearer $(gcloud auth print-access-token)"  \
    --data-binary @./vulnz_note.json  \
    "https://containeranalysis.googleapis.com/v1/projects/${ID}/notes/?noteId=${NOTE_ID}"

curl -vvv  \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "https://containeranalysis.googleapis.com/v1/projects/${ID}/notes/${NOTE_ID}"

ATTESTOR_ID=vulnz-attestor

gcloud container binauthz attestors create $ATTESTOR_ID \
    --attestation-authority-note=$NOTE_ID \
    --attestation-authority-note-project=${ID}

BINAUTHZ_SA_EMAIL="service-${PROJECT_NUMBER}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"

cat > ./iam_request.json << EOM
{
  'resource': 'projects/${ID}/notes/${NOTE_ID}',
  'policy': {
    'bindings': [
      {
        'role': 'roles/containeranalysis.notes.occurrences.viewer',
        'members': [
          'serviceAccount:${BINAUTHZ_SA_EMAIL}'
        ]
      }
    ]
  }
}
EOM

curl -X POST  \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    --data-binary @./iam_request.json \
    "https://containeranalysis.googleapis.com/v1/projects/${ID}/notes/${NOTE_ID}:setIamPolicy"

KEY_LOCATION=global
KEYRING=binauthz-keys
KEY_NAME=codelab-key
KEY_VERSION=1

gcloud kms keyrings create "${KEYRING}" --location="${KEY_LOCATION}"

gcloud kms keys create "${KEY_NAME}" \
    --keyring="${KEYRING}" --location="${KEY_LOCATION}" \
    --purpose asymmetric-signing   \
    --default-algorithm="ec-sign-p256-sha256"

gcloud beta container binauthz attestors public-keys add  \
    --attestor="${ATTESTOR_ID}"  \
    --keyversion-project="${ID}"  \
    --keyversion-location="${KEY_LOCATION}" \
    --keyversion-keyring="${KEYRING}" \
    --keyversion-key="${KEY_NAME}" \
    --keyversion="${KEY_VERSION}"

gcloud container binauthz attestors list

CONTAINER_PATH=$REGION-docker.pkg.dev/${ID}/artifact-scanning-repo/sample-image

DIGEST=$(gcloud container images describe ${CONTAINER_PATH}:latest \
    --format='get(image_summary.digest)')

gcloud beta container binauthz attestations sign-and-create  \
    --artifact-url="${CONTAINER_PATH}@${DIGEST}" \
    --attestor="${ATTESTOR_ID}" \
    --attestor-project="${ID}" \
    --keyversion-project="${ID}" \
    --keyversion-location="${KEY_LOCATION}" \
    --keyversion-keyring="${KEYRING}" \
    --keyversion-key="${KEY_NAME}" \
    --keyversion="${KEY_VERSION}"

gcloud container binauthz attestations list \
   --attestor=$ATTESTOR_ID --attestor-project=${ID}

gcloud beta container clusters create binauthz \
    --zone $ZONE  \
    --binauthz-evaluation-mode=PROJECT_SINGLETON_POLICY_ENFORCE

gcloud projects add-iam-policy-binding ${ID} \
        --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
        --role="roles/container.developer"

gcloud container binauthz policy export

kubectl run hello-server --image gcr.io/google-samples/hello-app:1.0 --port 8080

kubectl get pods

kubectl delete pod hello-server

gcloud container binauthz policy export  > policy.yaml

cat > policy.yaml <<EOF
globalPolicyEvaluationMode: ENABLE
defaultAdmissionRule:
  evaluationMode: ALWAYS_DENY
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
name: projects/$ID/policy
EOF

gcloud container binauthz policy import policy.yaml

kubectl run hello-server --image gcr.io/google-samples/hello-app:1.0 --port 8080

cat > policy.yaml <<EOF
globalPolicyEvaluationMode: ENABLE
defaultAdmissionRule:
  evaluationMode: ALWAYS_ALLOW
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
name: projects/$ID/policy
EOF

gcloud container binauthz policy import policy.yaml

display_yellow_message() {
    echo -e "\033[1;33mPlease check the Green Tick in Task 5 before moving further.\033[0m"
    read -p "If you are getting Green Tick in Task 5 then type 'y' to continue: " response
}

display_yellow_message

while [ "$response" != "y" ]; do
    display_yellow_message
done

echo "Continuing with the next steps..."

gcloud projects add-iam-policy-binding ${ID} \
  --member serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com \
  --role roles/binaryauthorization.attestorsViewer

gcloud projects add-iam-policy-binding ${ID} \
  --member serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com \
  --role roles/cloudkms.signerVerifier

gcloud projects add-iam-policy-binding ${ID} \
  --member serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com \
  --role roles/containeranalysis.notes.attacher

gcloud projects add-iam-policy-binding ${ID} \
        --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
        --role="roles/iam.serviceAccountUser"
        
gcloud projects add-iam-policy-binding ${ID} \
        --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
        --role="roles/ondemandscanning.admin"

git clone https://github.com/GoogleCloudPlatform/cloud-builders-community.git
cd cloud-builders-community/binauthz-attestation
gcloud builds submit . --config cloudbuild.yaml
cd ../..
rm -rf cloud-builders-community

cat > ./cloudbuild.yaml << EOF
steps:

- id: "build"
  name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', '$REGION-docker.pkg.dev/${ID}/artifact-scanning-repo/sample-image', '.']
  waitFor: ['-']

- id: "retag"
  name: 'gcr.io/cloud-builders/docker'
  args: ['tag',  '$REGION-docker.pkg.dev/${ID}/artifact-scanning-repo/sample-image', '$REGION-docker.pkg.dev/${ID}/artifact-scanning-repo/sample-image:good']

- id: "push"
  name: 'gcr.io/cloud-builders/docker'
  args: ['push',  '$REGION-docker.pkg.dev/${ID}/artifact-scanning-repo/sample-image:good']

#Sign the image only if the previous severity check passes
- id: 'create-attestation'
  name: 'gcr.io/${ID}/binauthz-attestation:latest'
  args:
    - '--artifact-url'
    - '$REGION-docker.pkg.dev/${ID}/artifact-scanning-repo/sample-image:good'
    - '--attestor'
    - 'projects/${ID}/attestors/$ATTESTOR_ID'
    - '--keyversion'
    - 'projects/${ID}/locations/$KEY_LOCATION/keyRings/$KEYRING/cryptoKeys/$KEY_NAME/cryptoKeyVersions/$KEY_VERSION'

images:
  - $REGION-docker.pkg.dev/${ID}/artifact-scanning-repo/sample-image:good
EOF

gcloud builds submit

COMPUTE_ZONE=$REGION

cat > binauth_policy.yaml << EOF
defaultAdmissionRule:
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
  evaluationMode: REQUIRE_ATTESTATION
  requireAttestationsBy:
  - projects/${ID}/attestors/vulnz-attestor
globalPolicyEvaluationMode: ENABLE
clusterAdmissionRules:
  ${COMPUTE_ZONE}.binauthz:
    evaluationMode: REQUIRE_ATTESTATION
    enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
    requireAttestationsBy:
    - projects/${ID}/attestors/vulnz-attestor
EOF

gcloud beta container binauthz policy import binauth_policy.yaml

CONTAINER_PATH=$REGION-docker.pkg.dev/${ID}/artifact-scanning-repo/sample-image

DIGEST=$(gcloud container images describe ${CONTAINER_PATH}:good \
    --format='get(image_summary.digest)')

cat > deploy.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: deb-httpd
spec:
  selector:
    app: deb-httpd
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deb-httpd
spec:
  replicas: 1
  selector:
    matchLabels:
      app: deb-httpd
  template:
    metadata:
      labels:
        app: deb-httpd
    spec:
      containers:
      - name: deb-httpd
        image: ${CONTAINER_PATH}@${DIGEST}
        ports:
        - containerPort: 8080
        env:
          - name: PORT
            value: "8080"
EOF

kubectl apply -f deploy.yaml

docker build -t $REGION-docker.pkg.dev/${ID}/artifact-scanning-repo/sample-image:bad .

docker push $REGION-docker.pkg.dev/${ID}/artifact-scanning-repo/sample-image:bad

CONTAINER_PATH=$REGION-docker.pkg.dev/${ID}/artifact-scanning-repo/sample-image

DIGEST=$(gcloud container images describe ${CONTAINER_PATH}:bad \
    --format='get(image_summary.digest)')

cat > deploy.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: deb-httpd
spec:
  selector:
    app: deb-httpd
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deb-httpd
spec:
  replicas: 1
  selector:
    matchLabels:
      app: deb-httpd
  template:
    metadata:
      labels:
        app: deb-httpd
    spec:
      containers:
      - name: deb-httpd
        image: ${CONTAINER_PATH}@${DIGEST}
        ports:
        - containerPort: 8080
        env:
          - name: PORT
            value: "8080"
EOF

kubectl apply -f deploy.yaml
```

## Lab Completed🎉