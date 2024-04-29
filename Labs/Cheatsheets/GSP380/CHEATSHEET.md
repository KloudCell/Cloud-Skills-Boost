# **To be done using Google Cloud Shell**

**1. Create a new Bigtable instance**

**2. Create and populate Bigtable tables**

**3. Create Bigtable table and dataflow job**

**4. Configure replication in Bigtable**

**5. Create Backup and restore data in Bigtable**

**6. Delete Bigtable data**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

INSTANCE=ecommerce-recommendations
CLUSTER=ecommerce-recommendations-c1
CLUSTER2=ecommerce-recommendations-c2
TABLE=SessionHistory
TABLE2=PersonalizedProducts

if [[ $ZONE == *c ]]; then
    ZONE_2="${ZONE%c}a"
elif [[ $ZONE == *b ]]; then
    ZONE_2="${ZONE%b}c"
else
    ZONE_2="${ZONE%b}c"
fi

echo "ZONE_2 value: $ZONE_2"

gcloud services disable dataflow
gcloud services enable dataflow

gcloud bigtable instances create $INSTANCE \
  --display-name="ecommerce-recommendations" \
  --cluster-storage-type=SSD \
  --cluster-config="id=$CLUSTER,zone=$ZONE"

gcloud bigtable clusters update $CLUSTER \
--instance=$INSTANCE \
--autoscaling-min-nodes=1 \
--autoscaling-max-nodes=5 \
--autoscaling-cpu-target=60

gsutil mb gs://$ID

gcloud bigtable instances tables create $TABLE \
 --instance=$INSTANCE   \
  --project=$ID   \
  --column-families=Engagements,Sales

gcloud dataflow jobs run import-sessions \
--gcs-location gs://dataflow-templates-$REGION/latest/GCS_SequenceFile_to_Cloud_Bigtable \
--region $REGION \
--staging-location gs://$ID/temp \
--additional-experiments {} \
--parameters bigtableProject=$ID,bigtableInstanceId=ecommerce-recommendations,bigtableTableId=SessionHistory,sourcePattern=gs://cloud-training/OCBL377/retail-engagements-sales-00000-of-00001,mutationThrottleLatencyMs=0

JOB_ID_1=$(gcloud dataflow jobs list --format="value(id)" --region $REGION| head -n 1)

while true; do
    JOB_STATE_1=$(gcloud dataflow jobs describe $JOB_ID_1 --region $REGION --format="value(currentState)")
    if [[ "$JOB_STATE_1" == "JOB_STATE_DONE" ]]; then
        echo "JOB 1 Done"
        break
    fi
done

gcloud bigtable instances tables create $TABLE2 \
 --instance=$INSTANCE   \
  --project=$ID   \
  --column-families=Recommendations

gcloud dataflow jobs run import-recommendations \
--gcs-location gs://dataflow-templates-$REGION/latest/GCS_SequenceFile_to_Cloud_Bigtable \
--region $REGION \
--staging-location gs://$ID/temp \
--additional-experiments {} \
--parameters bigtableProject=$ID,bigtableInstanceId=ecommerce-recommendations,bigtableTableId=PersonalizedProducts,sourcePattern=gs://cloud-training/OCBL377/retail-recommendations-00000-of-00001,mutationThrottleLatencyMs=0

JOB_ID_2=$(gcloud dataflow jobs list --format="value(id)" --region $REGION| tail -n 1)

while true; do
    JOB_STATE_2=$(gcloud dataflow jobs describe $JOB_ID_2 --region $REGION --format="value(currentState)")

    if [[ "$JOB_STATE_2" == "JOB_STATE_DONE" ]]; then
        echo "JOB 2 Done"
        break
    fi
    sleep 10
done

gcloud bigtable clusters create $CLUSTER2 \
 --async \
 --instance=$INSTANCE \
 --zone=$ZONE_2 \
--instance=$INSTANCE \
--autoscaling-min-nodes=1 \
--autoscaling-max-nodes=5 \
--autoscaling-cpu-target=60

gcloud  bigtable backups create PersonalizedProducts_7 --instance=$INSTANCE \
--cluster=$CLUSTER --table=$TABLE2 \
--retention-period=7d


gcloud bigtable instances tables restore \
--source=projects/$ID/instances/$INSTANCE/clusters/$CLUSTER/backups/PersonalizedProducts_7 \
--destination=PersonalizedProducts_7_restored \
--destination-instance=$INSTANCE \
--project=$ID

display_yellow_message() {
    echo -e "\033[1;33mPlease check the Green Tick in all the Tasks above 5th Task.\033[0m"
    read -p "If it is done, type 'y' to continue: " response
}

display_yellow_message

while [ "$response" != "y" ]; do
    display_yellow_message
done

echo "Continuing with the next steps..."

gcloud bigtable backups delete PersonalizedProducts_7 --instance=$INSTANCE --cluster=$CLUSTER --quiet

gcloud bigtable instances delete ecommerce-recommendations --quiet
```
## Lab Completed🎉