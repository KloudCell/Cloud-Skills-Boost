# **To be done using Google Cloud Shell**

**1. Create a MySQL database on Linux**

**2. Create a SQL Server database on Windows**

**3. Automate server creation using the Google Cloud SDK**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

cat <<'EOF' > mysql_setup.sh
sudo apt-get update
sudo apt-get install -y default-mysql-server

# Secure the MySQL installation
sudo mysql_secure_installation <<EOF_END

Enter current password for root (enter for none): 
N
N
N
N
N
Y
EOF_END

# Log in to the MySQL server
sudo mysql -u root -p -e "CREATE DATABASE petsdb; USE petsdb; CREATE TABLE pets (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), breed VARCHAR(255)); INSERT INTO pets (name, breed) VALUES ('Noir', 'Schnoodle');SELECT * FROM pets;"
EOF

gcloud compute instances create mysql-db \
  --zone=$ZONE \
  --image-family debian-11 \
  --image-project debian-cloud \
  --metadata-from-file startup-script=mysql_setup.sh \
  --tags mysql-server


gcloud compute instances create sql-server-db \
--project=$ID \
--zone=$ZONE \
--machine-type=e2-standard-4 \
--image-project windows-sql-cloud \
--image-family sql-web-2019-win-2019


gcloud compute instances create db-server \
--project=$ID \
--zone=$ZONE \
--machine-type=e2-medium \
--metadata=startup-script=\#\!\ /bin/bash$'\n'apt-get\ update$'\n'apt-get\ install\ -y\ default-mysql-server,enable-oslogin=true \
--image-family debian-11 \
--image-project debian-cloud
```
## Lab Completed🎉