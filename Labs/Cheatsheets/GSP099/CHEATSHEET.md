# **To be execute in Google Cloud Shell**

**1. Create a Cloud BigTable instance**

**2. Create a table**

**3. Delete the table**

```
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

gcloud bigtable instances create quickstart-instance \
    --display-name=quickstart-instance \
    --cluster-storage-type=SSD \
    --cluster-config=id=quickstart-instance-c1,zone=$ZONE

echo project = `gcloud config get-value project` > ~/.cbtrc

echo instance = quickstart-instance >> ~/.cbtrc

cbt createtable my-table

cbt ls

cbt createfamily my-table cf1

cbt ls my-table

cbt set my-table r1 cf1:c1=test-value

cbt read my-table

cbt deletetable my-table
```

## Lab Completed🎉