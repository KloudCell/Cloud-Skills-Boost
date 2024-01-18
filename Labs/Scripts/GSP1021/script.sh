#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

EMAIL=$(gcloud config get-value account)
ID=$(gcloud config get-value project)

# Modify the constraint

if (git clone https://github.com/GoogleCloudPlatform/policy-library.git

cd policy-library/
cp samples/iam_service_accounts_only.yaml policies/constraints

cat policies/constraints/iam_service_accounts_only.yaml

cat <<'EOF'> main.tf
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 3.84"
    }
  }
}

resource "google_project_iam_binding" "sample_iam_binding" {
  project = "<PROJECT>"
  role    = "roles/viewer"

  members = [
    "user:<EMAIL>"
  ]
}
EOF

sed -i "s/<PROJECT>/$ID/g" main.tf
sed -i "s/<EMAIL>/$EMAIL/g" main.tf

terraform init

terraform plan -out=test.tfplan

terraform show -json ./test.tfplan > ./tfplan.json

sudo apt-get install google-cloud-sdk-terraform-tools

gcloud beta terraform vet tfplan.json --policy-library=.


cd policies/constraints


cat <<'EOF'> iam_service_accounts_only.yaml
apiVersion: constraints.gatekeeper.sh/v1alpha1
kind: GCPIAMAllowedPolicyMemberDomainsConstraintV1
metadata:
  name: service_accounts_only
spec:
  severity: high
  match:
    target: ["organizations/**"]
  parameters:
    domains:
      - gserviceaccount.com
      - qwiklabs.net
EOF


cd ~

cd policy-library

terraform plan -out=test.tfplan

gcloud beta terraform vet tfplan.json --policy-library=.

terraform apply test.tfplan

terraform plan -out=test.tfplan

gcloud beta terraform vet tfplan.json --policy-library=.

terraform apply test.tfplan)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Constraint Modified: Checkpoint Completed (1/1)'
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all