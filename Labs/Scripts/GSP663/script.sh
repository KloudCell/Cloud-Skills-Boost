#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/enable.sh 2> /dev/null
. enable.sh

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
. common_code.sh

gcloud config set compute/zone $ZONE
gcloud services enable container.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Create a GKE cluster
if (gcloud container clusters create fancy-cluster --num-nodes 3)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Cluster Created: Checkpoint Completed (1/7)'

# Create Docker container with Cloud Build
    if (cd ~
    git clone https://github.com/googlecodelabs/monolith-to-microservices.git
    cd ~/monolith-to-microservices
    ./setup.sh
    nvm install --lts
    cd ~/monolith-to-microservices/monolith
    timeout 30 npm start

    cd ~/monolith-to-microservices/monolith
    gcloud builds submit --tag gcr.io/${ID}/monolith:1.0.0 .)

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Docker Created: Checkpoint Completed (2/7)'

# Deploy container to GKE
        if (kubectl create deployment monolith --image=gcr.io/${ID}/monolith:1.0.0)

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Container Deployed: Checkpoint Completed (3/7)'

# Expose GKE Deployment
            if (kubectl expose deployment monolith --type=LoadBalancer --port 80 --target-port 8080)

            then
                sleep 30
                printf "\n\e[1;96m%s\n\n\e[m" 'Deployment Exposed: Checkpoint Completed (4/7)'

# Scale GKE deployment
                if (kubectl scale deployment monolith --replicas=3 && sleep 30)

                then
                    printf "\n\e[1;96m%s\n\n\e[m" 'Deployment Scaled: Checkpoint Completed (5/7)'

# Make changes to the website
                    if (cd ~/monolith-to-microservices/react-app/src/pages/Home
                    mv index.js.new index.js

                    cd ~/monolith-to-microservices/react-app
                    npm run build:monolith

                    cd ~/monolith-to-microservices/monolith
                    gcloud builds submit --tag gcr.io/${ID}/monolith:2.0.0 .)

                    then
                        printf "\n\e[1;96m%s\n\n\e[m" 'Website Changed: Checkpoint Completed (6/7)'

# Update website with zero downtime
                        if (kubectl set image deployment/monolith monolith=gcr.io/${ID}/monolith:2.0.0 &&\
                        timeout 60 npm start)

                        then
                            printf "\n\e[1;96m%s\n\n\e[m" 'Website Updated: Checkpoint Completed (7/7)'
                        fi
                    fi
                fi
            fi
        fi
    fi
    printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all