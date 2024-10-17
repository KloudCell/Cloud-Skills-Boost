# **To be done using Google Cloud Shell**

**1. Create Namespaces**

**2. Access Control in Namespaces**

**3. Resource Quotas**

**4. Monitoring GKE and GKE Usage Metering**

```bash
wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

export GCP_BILLING_EXPORT_TABLE_FULL_PATH=${ID}.billing_dataset.gcp_billing_export_v1_xxxx
export USAGE_METERING_DATASET_ID=cluster_dataset
export COST_BREAKDOWN_TABLE_ID=usage_metering_cost_breakdown

export USAGE_METERING_QUERY_TEMPLATE=~/gke-qwiklab/usage_metering_query_template.sql
export USAGE_METERING_QUERY=cost_breakdown_query.sql
export USAGE_METERING_START_DATE=2020-10-26

gsutil -m cp -r gs://spls/gsp766/gke-qwiklab ~

cd ~/gke-qwiklab

gcloud config set compute/zone ${ZONE} && gcloud container clusters get-credentials multi-tenant-cluster

kubectl create namespace team-a && \
kubectl create namespace team-b

kubectl run app-server --image=centos --namespace=team-a -- sleep infinity && \
kubectl run app-server --image=centos --namespace=team-b -- sleep infinity

kubectl config set-context --current --namespace=team-a

gcloud projects add-iam-policy-binding ${ID} \
--member=serviceAccount:team-a-dev@${ID}.iam.gserviceaccount.com  \
--role=roles/container.clusterViewer

kubectl create role pod-reader \
--resource=pods --verb=watch --verb=get --verb=list

kubectl create -f developer-role.yaml

kubectl create rolebinding team-a-developers \
--role=developer --user=team-a-dev@${ID}.iam.gserviceaccount.com

gcloud iam service-accounts keys create /tmp/key.json --iam-account team-a-dev@${ID}.iam.gserviceaccount.com

gcloud container clusters get-credentials multi-tenant-cluster --zone ${ZONE} --project ${ID}

kubectl create quota test-quota \
--hard=count/pods=2,count/services.loadbalancers=1 --namespace=team-a

kubectl run app-server-2 --image=centos --namespace=team-a -- sleep infinity

kubectl run app-server-3 --image=centos --namespace=team-a -- sleep infinity

sleep 21

kubectl get quota test-quota --namespace=team-a -o yaml | \
  sed 's/count\/pods: "2"/count\/pods: "6"/' | \
  kubectl apply -f -

kubectl create -f cpu-mem-quota.yaml

kubectl create -f cpu-mem-demo-pod.yaml --namespace=team-a

gcloud container clusters \
  update multi-tenant-cluster --zone ${ZONE} \
  --resource-usage-bigquery-dataset cluster_dataset

sed \
-e "s/\${fullGCPBillingExportTableID}/$GCP_BILLING_EXPORT_TABLE_FULL_PATH/" \
-e "s/\${projectID}/$ID/" \
-e "s/\${datasetID}/$USAGE_METERING_DATASET_ID/" \
-e "s/\${startDate}/$USAGE_METERING_START_DATE/" \
"$USAGE_METERING_QUERY_TEMPLATE" \
> "$USAGE_METERING_QUERY"

bq query \
--project_id=$ID \
--use_legacy_sql=false \
--destination_table=$USAGE_METERING_DATASET_ID.$COST_BREAKDOWN_TABLE_ID \
--schedule='every 24 hours' \
--display_name="GKE Usage Metering Cost Breakdown Scheduled Query" \
--replace=true \
"$(cat $USAGE_METERING_QUERY)"
```
- Goto [Create the data source in Looker Studio](https://www.cloudskillsboost.google/focuses/14861?parent=catalog#:~:text=Create%20the%20data%20source%20in%20Looker%20Studio) of `Task 5` and do it as mentioned in the lab

## Lab Completed🎉