# **To be done using Google Cloud Shell**

**1. Create a new dataset and table to store the data**

**2. Execute the query to see how many unique products were viewed**

**3. Execute the query to use the UNNEST() on array field**

**4. Create a dataset and a table to ingest JSON data**

**5. Execute the query to COUNT how many racers were there in total**

**6. Execute the query that will list the total race time for racers whose names begin with R**

**7. Execute the query to see which runner ran fastest lap time**

```bash
bq mk fruit_store

bq mk --table fruit_store.fruit_details

bq load --source_format=NEWLINE_DELIMITED_JSON \
--autodetect fruit_store.fruit_details gs://data-insights-course/labs/optimizing-for-performance/shopping_cart.json

bq query --use_legacy_sql=false \
"SELECT
  fullVisitorId,
  date,
  ARRAY_AGG(DISTINCT v2ProductName) AS products_viewed,
  ARRAY_LENGTH(ARRAY_AGG(DISTINCT v2ProductName)) AS distinct_products_viewed,
  ARRAY_AGG(DISTINCT pageTitle) AS pages_viewed,
  ARRAY_LENGTH(ARRAY_AGG(DISTINCT pageTitle)) AS distinct_pages_viewed
  FROM \`data-to-insights.ecommerce.all_sessions\`
WHERE visitId = 1501570398
GROUP BY fullVisitorId, date
ORDER BY date;"

bq query --use_legacy_sql=false \
"SELECT DISTINCT
  visitId,
  h.page.pageTitle
FROM \`bigquery-public-data.google_analytics_sample.ga_sessions_20170801\`,
UNNEST(hits) AS h
WHERE visitId = 1501570398
LIMIT 10;"

echo '[
    {
        "name": "race",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "participants",
        "type": "RECORD",
        "mode": "REPEATED",
        "fields": [
            {
                "name": "name",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "splits",
                "type": "FLOAT",
                "mode": "REPEATED"
            }
        ]
    }
]' > schema.json

bq mk racing

bq mk --table --schema=schema.json  racing.race_results

bq load --source_format=NEWLINE_DELIMITED_JSON \
--schema=schema.json racing.race_results gs://data-insights-course/labs/optimizing-for-performance/race_results.json

bq query --use_legacy_sql=false \
"SELECT COUNT(p.name) AS racer_count
FROM racing.race_results AS r, UNNEST(r.participants) AS p;"

bq query --use_legacy_sql=false \
"SELECT
  p.name,
  SUM(split_times) as total_race_time
FROM racing.race_results AS r
, UNNEST(r.participants) AS p
, UNNEST(p.splits) AS split_times
WHERE p.name LIKE 'R%'
GROUP BY p.name
ORDER BY total_race_time ASC;
"
sleep 7

bq query --use_legacy_sql=false \
"SELECT
  p.name,
  split_time
FROM racing.race_results AS r
, UNNEST(r.participants) AS p
, UNNEST(p.splits) AS split_time
WHERE split_time = 23.2;"
```

## Lab Completed🎉