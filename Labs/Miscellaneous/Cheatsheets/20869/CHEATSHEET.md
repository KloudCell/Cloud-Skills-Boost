# **To be done using Google Cloud Shell**

**1. Create a Cloud SQL PostgreSQL instance**

**2. Create a database on Cloud SQL PostgreSQL instance**

**3. Create a Cloud SQL MySQL database using the CLI**

**4. Connect to the MySQL database from a virtual machine**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

INSTANCE_NAME="mysql-db"

gcloud sql instances create postgresql-db \
--database-version=POSTGRES_14 \
--zone=$ZONE \
--tier=db-custom-1-3840 \
--root-password=kloudcell \
--edition=ENTERPRISE

gcloud sql databases create petsdb --instance=postgresql-db

gcloud sql instances create mysql-db --tier=db-n1-standard-1 --zone=$ZONE

gcloud compute instances create test-client  --zone=$ZONE --image-family=debian-11 --image-project=debian-cloud --machine-type=e2-micro

EXTERNAL=$(gcloud compute instances list --format='value(EXTERNAL_IP)')

gcloud sql instances patch $INSTANCE_NAME \
  --authorized-networks=$EXTERNAL \
  --quiet

PUBLIC_IP=$(gcloud sql instances describe $INSTANCE_NAME --format="value(ipAddresses.ipAddress)")

gcloud compute ssh test-client --zone=$ZONE <<EOF
  # Update package lists
  sudo apt-get update

  # Install MySQL client
  sudo apt-get install -y default-mysql-client

  # Log in to the database server
  mysql --host=$PUBLIC_IP --user=root --password
EOF

sleep 21

gcloud compute ssh test-client --zone=$ZONE <<EOF
  # Update package lists
  sudo apt-get update

  # Install MySQL client
  sudo apt-get install -y default-mysql-client

  # Log in to the database server
  mysql --host=$PUBLIC_IP --user=root --password
EOF

sleep 21

gcloud compute ssh test-client --zone=$ZONE <<EOF
  # Update package lists
  sudo apt-get update

  # Install MySQL client
  sudo apt-get install -y default-mysql-client

  # Log in to the database server
  mysql --host=$PUBLIC_IP --user=root --password
EOF
```

## Lab Completed🎉