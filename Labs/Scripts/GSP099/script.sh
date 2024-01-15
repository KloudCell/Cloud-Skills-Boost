#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

# Create a Cloud BigTable instance
if (gcloud bigtable instances create quickstart-instance \
    --display-name=quickstart-instance \
    --cluster-storage-type=SSD \
    --cluster-config=id=quickstart-instance-c1,zone=$ZONE)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Instance Created: Checkpoint Completed (1/3)'

    echo project = `gcloud config get-value project` > ~/.cbtrc

    echo instance = quickstart-instance >> ~/.cbtrc

# Create a table
    if (cbt createtable my-table)

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Table Created: Checkpoint Completed (2/3)'

        if (cbt deletetable my-table)

# Delete the table
        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Table Deleted: Checkpoint Completed (3/3)'
        fi
    fi
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all