#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
source common_code.sh

export IV_BUCKET_NAME=$ID-upload
export FILTERED_BUCKET_NAME=$ID-filtered
export FLAGGED_BUCKET_NAME=$ID-flagged
export STAGING_BUCKET_NAME=$ID-staging
export UPLOAD_NOTIFICATION_TOPIC=upload_notification
export DATASET_ID=intelligentcontentfilter
export TABLE_NAME=filtered_content

wget -O demo-image.jpg https://cdn.qwiklabs.com/3hpf8ZMmvpav2QvPqQCY1Zl1O%2B%2F8rrass6yjAPki3Dc%3D

# Creating Cloud Storage buckets
if (gsutil mb gs://${IV_BUCKET_NAME}

gsutil mb gs://${FILTERED_BUCKET_NAME}

gsutil mb gs://${FLAGGED_BUCKET_NAME}

gsutil mb gs://${STAGING_BUCKET_NAME})

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Buckets Created: Checkpoint Completed (1/6)'

# Creating Cloud Pub/Sub topics
    if (gcloud pubsub topics create ${UPLOAD_NOTIFICATION_TOPIC}

    gcloud pubsub topics create visionapiservice

    gcloud pubsub topics create videointelligenceservice

    gcloud pubsub topics create bqinsert)

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Pub/Sub Topics Created: Checkpoint Completed (2/6)'

# Creating Cloud Storage notifications
        if (gsutil notification create -t upload_notification -f json -e OBJECT_FINALIZE gs://${IV_BUCKET_NAME})

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Cloud Storage Notification Created: Checkpoint Completed (3/6)'

# Create the BigQuery dataset and table
            if (gsutil -m cp -r gs://spls/gsp138/cloud-functions-intelligentcontent-nodejs .

            cd cloud-functions-intelligentcontent-nodejs

            bq --project_id ${ID} mk ${DATASET_ID}

            bq --project_id ${ID} mk --schema intelligent_content_bq_schema.json -t ${DATASET_ID}.${TABLE_NAME}

            bq --project_id ${ID} show ${DATASET_ID}.${TABLE_NAME})

            then
                printf "\n\e[1;96m%s\n\n\e[m" 'API Key Created: Checkpoint Completed (4/6)'

# Deploying the Cloud Functions
                if (cd cloud-functions-intelligentcontent-nodejs
                sed -i "s/\[PROJECT-ID\]/$ID/g" config.json

                sed -i "s/\[FLAGGED_BUCKET_NAME\]/$FLAGGED_BUCKET_NAME/g" config.json

                sed -i "s/\[FILTERED_BUCKET_NAME\]/$FILTERED_BUCKET_NAME/g" config.json

                sed -i "s/\[DATASET_ID\]/$DATASET_ID/g" config.json


                sed -i "s/\[TABLE_NAME\]/$TABLE_NAME/g" config.json


                gcloud functions deploy GCStoPubsub --runtime nodejs10 --stage-bucket gs://${STAGING_BUCKET_NAME} --trigger-topic ${UPLOAD_NOTIFICATION_TOPIC} --entry-point GCStoPubsub --region $REGION --quiet

                gcloud functions deploy visionAPI --runtime nodejs10 --stage-bucket gs://${STAGING_BUCKET_NAME} --trigger-topic visionapiservice --entry-point visionAPI --region $REGION

                gcloud functions deploy videoIntelligenceAPI --runtime nodejs10 --stage-bucket gs://${STAGING_BUCKET_NAME} --trigger-topic videointelligenceservice --entry-point videoIntelligenceAPI --timeout 540 --region $REGION --quiet

                gcloud functions deploy insertIntoBigQuery --runtime nodejs10 --stage-bucket gs://${STAGING_BUCKET_NAME} --trigger-topic bqinsert --entry-point insertIntoBigQuery --region $REGION --quiet)

                then
                    printf "\n\e[1;96m%s\n\n\e[m" 'BigQuery dataset and table created: Checkpoint Completed (5/6)'

# Testing the flow
                    if (gsutil cp demo-image.jpg gs://$IV_BUCKET_NAME

                    while [[ $(gcloud beta functions logs read --filter "finished with status" "GCStoPubsub" --limit 100 --region $REGION) != *"finished with status"* ]]; do echo "Waiting for logs for GCStoPubsub..."; sleep 10; done
                    gcloud beta functions logs read --filter "finished with status" "insertIntoBigQuery" --limit 100 --region $REGION


                    echo "
                    #standardSql

                    SELECT insertTimestamp,
                    contentUrl,
                    flattenedSafeSearch.flaggedType,
                    flattenedSafeSearch.likelihood
                    FROM \`$ID.$DATASET_ID.$TABLE_NAME\`
                    CROSS JOIN UNNEST(safeSearch) AS flattenedSafeSearch
                    ORDER BY insertTimestamp DESC,
                    contentUrl,
                    flattenedSafeSearch.flaggedType
                    LIMIT 1000
                    " > sql.txt

                    bq --project_id ${ID} query < sql.txt)

                    then
                        printf "\n\e[1;96m%s\n\n\e[m" 'Test Completed: Checkpoint Completed (6/6)'
                    fi
                fi
            fi
        fi
    fi
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all
