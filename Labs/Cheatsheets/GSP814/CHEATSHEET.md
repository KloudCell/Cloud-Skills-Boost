# **To be done using Google Cloud Shell**

**1. Enable the Data Catalog API**

**2. Create the SQLServer Database**

**3. Set Up the Service Account for SQLServer**

**4. Execute SQLServer to Data Catalog connector**

**5. Create the PostgreSQL Database**

**6. Create a Service Account for postgresql**

**7. Execute PostgreSQL to Data Catalog connector**

**8. Create the MySQL Database**

**9. Create a Service Account for MySQL**

**10. Execute MySQL to Data Catalog connector**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud services enable datacatalog.googleapis.com

sleep 7

gsutil cp gs://spls/gsp814/cloudsql-sqlserver-tooling.zip .
unzip cloudsql-sqlserver-tooling.zip

cd cloudsql-sqlserver-tooling/infrastructure/terraform

sed -i "s/us-central1/$REGION/g" variables.tf

cd ~/cloudsql-sqlserver-tooling
bash init-db.sh

init-db

gcloud iam service-accounts create sqlserver2dc-credentials \
--display-name  "Service Account for SQL Server to Data Catalog connector" \
--project $ID

gcloud iam service-accounts keys create "sqlserver2dc-credentials.json" \
--iam-account "sqlserver2dc-credentials@$ID.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $ID \
--member "serviceAccount:sqlserver2dc-credentials@$ID.iam.gserviceaccount.com" \
--quiet \
--project $ID \
--role "roles/datacatalog.admin"

cd infrastructure/terraform/

public_ip_address=$(terraform output -raw public_ip_address)
username=$(terraform output -raw username)
password=$(terraform output -raw password)
database=$(terraform output -raw db_name)

cd ~/cloudsql-sqlserver-tooling

docker run --rm --tty -v \
"$PWD":/data mesmacosta/sqlserver2datacatalog:stable \
--datacatalog-project-id=$ID \
--datacatalog-location-id=$REGION \
--sqlserver-host=$public_ip_address \
--sqlserver-user=$username \
--sqlserver-pass=$password \
--sqlserver-database=$database

docker run --rm --tty -v \
"$PWD":/data mesmacosta/sqlserver-datacatalog-cleaner:stable \
--datacatalog-project-ids=$ID \
--rdbms-type=sqlserver \
--table-container-type=schema

cd

gsutil cp gs://spls/gsp814/cloudsql-postgresql-tooling.zip .
unzip cloudsql-postgresql-tooling.zip

cd cloudsql-postgresql-tooling/infrastructure/terraform

sed -i "s/us-central1/$REGION/g" variables.tf

cd ~/cloudsql-postgresql-tooling
bash init-db.sh

init-db

gcloud iam service-accounts create postgresql2dc-credentials \
--display-name  "Service Account for PostgreSQL to Data Catalog connector" \
--project $ID

gcloud iam service-accounts keys create "postgresql2dc-credentials.json" \
--iam-account "postgresql2dc-credentials@$ID.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $ID \
--member "serviceAccount:postgresql2dc-credentials@$ID.iam.gserviceaccount.com" \
--quiet \
--project $ID \
--role "roles/datacatalog.admin"

cd infrastructure/terraform/

public_ip_address=$(terraform output -raw public_ip_address)
username=$(terraform output -raw username)
password=$(terraform output -raw password)
database=$(terraform output -raw db_name)

cd ~/cloudsql-postgresql-tooling

docker run --rm --tty -v \
"$PWD":/data mesmacosta/postgresql2datacatalog:stable \
--datacatalog-project-id=$ID \
--datacatalog-location-id=$REGION \
--postgresql-host=$public_ip_address \
--postgresql-user=$username \
--postgresql-pass=$password \
--postgresql-database=$database

docker run --rm --tty -v \
"$PWD":/data mesmacosta/postgresql-datacatalog-cleaner:stable \
--datacatalog-project-ids=$ID \
--rdbms-type=postgresql \
--table-container-type=

cd

gsutil cp gs://spls/gsp814/cloudsql-mysql-tooling.zip .
unzip cloudsql-mysql-tooling.zip

cd cloudsql-mysql-tooling/infrastructure/terraform

sed -i "s/us-central1/$REGION/g" variables.tf

cd ~/cloudsql-mysql-tooling
bash init-db.sh

init-db

gcloud iam service-accounts create mysql2dc-credentials \
--display-name  "Service Account for MySQL to Data Catalog connector" \
--project $ID

gcloud iam service-accounts keys create "mysql2dc-credentials.json" \
--iam-account "mysql2dc-credentials@$ID.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $ID \
--member "serviceAccount:mysql2dc-credentials@$ID.iam.gserviceaccount.com" \
--quiet \
--project $ID \
--role "roles/datacatalog.admin"

cd infrastructure/terraform/

public_ip_address=$(terraform output -raw public_ip_address)
username=$(terraform output -raw username)
password=$(terraform output -raw password)
database=$(terraform output -raw db_name)

cd ~/cloudsql-mysql-tooling

docker run --rm --tty -v \
"$PWD":/data mesmacosta/mysql2datacatalog:stable \
--datacatalog-project-id=$ID \
--datacatalog-location-id=$REGION \
--mysql-host=$public_ip_address \
--mysql-user=$username \
--mysql-pass=$password \
--mysql-database=$database
```

## Lab Completed🎉