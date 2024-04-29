# **To be done using Google Cloud Shell**

**Working with Backends**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

cat <<'EOF'> main.tf
provider "google" {
  project     = "PROJECT_ID"
  region      = "REGION"
}
resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "PROJECT_ID"
  location    = "US"
  uniform_bucket_level_access = true
}

terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}
EOF

sed -i "s/PROJECT_ID/${ID}/g" main.tf
sed -i "s/REGION/${REGION}/g" main.tf

terraform init
terraform apply --auto-approve


cat <<'EOF'> main.tf
provider "google" {
  project     = "PROJECT_ID"
  region      = "REGION"
}
resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "PROJECT_ID"
  location    = "US"
  uniform_bucket_level_access = true
}

terraform {
  backend "gcs" {
    bucket  = "PROJECT_ID"
    prefix  = "terraform/state"
  }
}
EOF

sed -i "s/PROJECT_ID/${ID}/g" main.tf
sed -i "s/REGION/${REGION}/g" main.tf

yes | terraform init -migrate-state

gsutil label ch -l "key:value" gs://$ID
```
## Lab Completed🎉