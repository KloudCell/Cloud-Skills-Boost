# **To be done using Google Cloud Shell**

**1. Query a public dataset (dataset: samples, table: natality)**

**2. Create a new dataset**

**3. Load data into your table**

**4. Query a custom dataset**

```sql
bq query --nouse_legacy_sql \
'SELECT
 weight_pounds, state, year, gestation_weeks
FROM
 `bigquery-public-data.samples.natality`
ORDER BY weight_pounds DESC LIMIT 10;'

bq mk babynames

bq load --autodetect --source_format=CSV babynames.names_2014 gs://spls/gsp072/baby-names/yob2014.txt name:string,gender:string,count:integer

bq query --nouse_legacy_sql \
"SELECT
 name, count
FROM
 \`babynames.names_2014\`
WHERE
 gender = 'M'
ORDER BY count DESC LIMIT 5;"
```

## Lab Completed🎉