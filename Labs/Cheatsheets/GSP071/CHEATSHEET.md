# **To be execute in Google Cloud Shell**

**1. Run a query (dataset: samples, table: shakespeare, substring: raisin)**

    bq query --use_legacy_sql=false \
    'SELECT
    word,
    SUM(word_count) AS count
    FROM
    `bigquery-public-data`.samples.shakespeare
    WHERE
    word LIKE "%raisin%"
    GROUP BY
    word'

**2. Run a query (dataset: samples, table: shakespeare, substring: huzzah)**

    bq query --use_legacy_sql=false \
    'SELECT
    word
    FROM
    `bigquery-public-data`.samples.shakespeare
    WHERE
    word = "huzzah"'

**3. Create a new dataset (name: babynames)**

    bq mk babynames

**4. Load the data into a new table**

    curl -LO http://www.ssa.gov/OACT/babynames/names.zip

    unzip names.zip

    bq load babynames.names2010 yob2010.txt name:string,gender:string,count:integer

**5. Run queries against your dataset table**

    bq query "SELECT name,count FROM babynames.names2010 WHERE gender = 'F' ORDER BY count DESC LIMIT 5"

    bq query "SELECT name,count FROM babynames.names2010 WHERE gender = 'M' ORDER BY count ASC LIMIT 5"

**6. Remove the babynames dataset**

    echo "y" >  yes

    sleep 10

    bq rm -r babynames < yes

## Lab Completed🎉