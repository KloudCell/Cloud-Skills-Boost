# **To be execute in Google Cloud Shell**

**1. Create an API key**

**2. Classify a news article**

**3. Create a BigQuery table for categorized text data**

    gcloud services enable \
    language.googleapis.com
    wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/common_code.sh 2> /dev/null
    source common_code.sh

    cat <<'EOF'> a.sh
    export API_KEY=YOUR_API_KEY

    echo '{
    "document":{
        "type":"PLAIN_TEXT",
        "content":"A Smoky Lobster Salad With a Tapa Twist. This spin on the Spanish pulpo a la gallega skips the octopus, but keeps the sea salt, olive oil, pimentón and boiled potatoes."
    }
    }' > request.json

    curl "https://language.googleapis.com/v1/documents:classifyText?key=${API_KEY}" \
    -s -X POST -H "Content-Type: application/json" --data-binary @request.json > result.json
    EOF

    sed -i "s/YOUR_API_KEY/$API_KEY/g" a.sh

    gcloud compute ssh linux-instance --zone $ZONE --project "$ID" --quiet --command "bash -s" < a.sh 

    bq mk --dataset news_classification_dataset

    bq mk --table news_classification_dataset.article_data article_text:string,category:string,confidence:float

## Lab Completed🎉