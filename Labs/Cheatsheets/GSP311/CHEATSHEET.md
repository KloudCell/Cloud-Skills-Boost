# **To be done using Google Cloud Console and Shell**

### **Setup and requirements**

    wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
    . common_code.sh

***Get Bucket Name from Task 1***

    export BUCKET_NAME=

***Get Dataset Name from Task 3***

    export DATASET_NAME=

***Get Topic Name from Task 4***

    export TOPIC_NAME=

***Get Staging Bucket Name from Task 5***

    export BUCKET_NAME_2=

***Get Dataflow Object Name from Task 5***

    export DATAFLOW_OBJECT_NAME=

**1. Create a Cloud Storage bucket**

**2. Create a Cloud function**

**3. Create a BigQuery dataset**

**4. Create Cloud Pub/Sub topic**

**5. Create a Cloud Storage bucket for staging contents**

**6. Deploy a Cloud dataflow pipeline**

    git clone https://github.com/GoogleCloudPlatform/dataflow-contact-center-speech-analysis.git
    gsutil mb -l $REGION gs://$BUCKET_NAME/
    cd dataflow-contact-center-speech-analysis/saf-longrun-job-func
    gcloud functions deploy safLongRunJobFunc --runtime nodejs12 --trigger-resource $BUCKET_NAME --region $REGION --trigger-event google.storage.object.finalize

    bq mk $DATASET_NAME

    gcloud pubsub topics create $TOPIC_NAME

    gsutil mb -l $REGION gs://$BUCKET_NAME_2/
    gsutil cp /dev/null gs://$BUCKET_NAME_2/$DATAFLOW_OBJECT_NAME/

    cd ..

    cd saf-longrun-job-dataflow

    python -m virtualenv env -p python3
    source env/bin/activate
    pip install apache-beam[gcp]
    pip install dateparser

**7. Upload sample audio files for processing**

**8. Run a data loss prevention job**

    python saflongrunjobdataflow.py \
    --project=$DEVSHELL_PROJECT_ID \
    --region=$REGION \
    --input_topic=projects/$DEVSHELL_PROJECT_ID/topics/$TOPIC_NAME \
    --runner=DataflowRunner \
    --temp_location=gs://$BUCKET_NAME/$DATAFLOW_OBJECT_NAME \
    --output_bigquery=$DEVSHELL_PROJECT_ID:$DATASET_NAME.transcripts \
    --requirements_file=requirements.txt

    sleep 20

    # Get the initial state of the most recently created job
    STATE=$(gcloud dataflow jobs list --sort-by=~CREATION_TIME --limit=1 --region $REGION --format="value(STATE)")

    # While the state is not 'Running', sleep for 20 seconds and then check again
    while [ "$STATE" != "Running" ]
    do
        echo "Job not running, state is $STATE. Rerunnig the cmd..."
        python saflongrunjobdataflow.py \
        --project=$DEVSHELL_PROJECT_ID \
        --region=$REGION \
        --input_topic=projects/$DEVSHELL_PROJECT_ID/topics/$TOPIC_NAME \
        --runner=DataflowRunner \
        --temp_location=gs://$BUCKET_NAME/$DATAFLOW_OBJECT_NAME \
        --output_bigquery=$DEVSHELL_PROJECT_ID:$DATASET_NAME.transcripts \
        --requirements_file=requirements.txt
        sleep 20
        STATE=$(gcloud dataflow jobs list --sort-by=~CREATION_TIME --limit=1 --region $REGION --format="value(STATE)")
    done

    # State is 'Running',
    echo -e "\033[0;32mJob is running. Now, executing the next cmds...\033[0m"

        # mono flac audio sample
    gsutil -h x-goog-meta-dlp:false -h x-goog-meta-callid:1234567 -h x-goog-meta-stereo:false -h x-goog-meta-pubsubtopicname:$TOPIC_NAME -h x-goog-meta-year:2019 -h x-goog-meta-month:11 -h x-goog-meta-day:06 -h x-goog-meta-starttime:1116 cp gs://qwiklabs-bucket-gsp311/speech_commercial_mono.flac gs://$BUCKET_NAME



        # stereo wav audio sample
    gsutil -h x-goog-meta-dlp:false -h x-goog-meta-callid:1234567 -h x-goog-meta-stereo:true -h x-goog-meta-pubsubtopicname:$TOPIC_NAME -h x-goog-meta-year:2019 -h x-goog-meta-month:11 -h x-goog-meta-day:06 -h x-goog-meta-starttime:1116 cp gs://qwiklabs-bucket-gsp311/speech_commercial_stereo.wav gs://$BUCKET_NAME

    sleep 300

    cat << 'EOF' > check.py
    from google.cloud import bigquery

    # Construct a BigQuery client object.
    client = bigquery.Client()

    datasets = list(client.list_datasets())  # Make an API request.
    table_exists = False

    for dataset in datasets:
        dataset_id = dataset.dataset_id
        tables = client.list_tables(dataset_id)  # Make an API request.
        for table in tables:
            if table.table_id == "transcripts":
                table_exists = True
                break

    if table_exists:
        print("Table transcripts exists.")
    else:
        print("Table transcripts does not exist.")
    EOF

    CHECK=$(python check.py)

    while [ "$CHECK" != "Table transcripts exists." ]
    do
        python check.py
        echo "Wait, while table transcripts is being created"
    done

    echo -e "\033[0;32mTable transcripts created\033[0m"


    bq query --use_legacy_sql=false \
    --destination_table=$DEVSHELL_PROJECT_ID:$DATASET_NAME.saf \
    "SELECT entities.name, entities.type, COUNT(entities.name) AS count
    FROM $DATASET_NAME.transcripts, UNNEST(entities) entities
    GROUP BY entities.name, entities.type
    HAVING count > 5
    ORDER BY count ASC"

    bq query --use_legacy_sql=false \
    --destination_table=$DEVSHELL_PROJECT_ID:$DATASET_NAME.kloud \
    "SELECT entities.name, entities.type, COUNT(entities.name) AS count
    FROM $DATASET_NAME.transcripts, UNNEST(entities) entities
    GROUP BY entities.name, entities.type
    HAVING count > 5
    ORDER BY count ASC"

**Now, go to the link echoed after running below cmd**

    echo https://console.cloud.google.com/bigquery?referrer=search&project=$ID

***Click on "kloud" table -> Export -> Scan with Sensitive Data Protection***

***Now put your "PROJECT ID" in "Job ID" field and click "Create"***

### **Lab Done🎉**




