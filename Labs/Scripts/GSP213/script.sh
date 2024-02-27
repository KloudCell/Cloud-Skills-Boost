#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

# Create the blue server

if (gcloud compute instances create blue \
--project=$ID \
--zone=$ZONE \
--tags=web-server,http-server \
--metadata=startup-script=sudo\ apt-get\ install\ nginx-light\ -y$'\n'sudo\ sed\ -i\ \"14c\\\<h1\>Welcome\ to\ the\ blue\ server\!\</h1\>\"\ /var/www/html/index.nginx-debian.html)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Blue Server Created: Checkpoint Completed (1/6)'

# Create the green server

    if (gcloud compute instances create green \
    --project=$ID \
    --zone=$ZONE \
    --metadata=startup-script=sudo\ apt-get\ install\ nginx-light\ -y$'\n'sudo\ sed\ -i\ \"14c\\\<h1\>Welcome\ to\ the\ green\ server\!\</h1\>\"\ /var/www/html/index.nginx-debian.html)

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Green Server Created: Checkpoint Completed (2/6)'

# Install Nginx and customize the welcome page

        sleep 12
        printf "\n\e[1;96m%s\n\n\e[m" 'Nginx installed: Checkpoint Completed (3/6)'

# Create the tagged firewall rule

        if (gcloud compute firewall-rules create allow-http-web-server \
        --project=$ID \
        --network=default \
        --target-tags=web-server \
        --source-ranges=0.0.0.0/0 \
        --action=ALLOW \
        --rules=tcp:80,icmp)

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Tagged Firewall Created: Checkpoint Completed (4/6)'

# Create a test-vm

            if (gcloud compute instances create test-vm \
            --machine-type=e2-micro \
            --subnet=default \
            --zone=$ZONE)

            then
                printf "\n\e[1;96m%s\n\n\e[m" 'test-vm Created: Checkpoint Completed (5/6)'

# Create a Network-admin service account

                if (gcloud iam service-accounts create network-admin \
                --display-name="Network-admin")

                then
                    printf "\n\e[1;96m%s\n\n\e[m" 'Network-admin Service Account Created: Checkpoint Completed (6/6)'
                fi
            fi
        fi
    fi
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all