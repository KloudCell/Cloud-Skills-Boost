#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

# Deploy GKE cluster
if (gcloud beta container --project "$ID" clusters create "standard-cluster-1" --zone $ZONE)

then
    sleep 33 && printf "\n\e[1;96m%s\n\n\e[m" 'GKE Cluster Deployed: Checkpoint Completed (1/3)'

# Modify GKE clusters
    if (gcloud container clusters resize standard-cluster-1 --num-nodes=4 --zone $ZONE -q)

    then
        sleep 33 && printf "\n\e[1;96m%s\n\n\e[m" 'GKE cluster Modified: Checkpoint Completed (2/3)'

# Deploy a sample nginx workload
        if (kubectl create deployment nginx-1 --image=nginx:latest)

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Workload Deployed: Checkpoint Completed (3/3)'
        fi
    fi
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all
