#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

# Create a BigQuery dataset
if (bq mk bqml_lab)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'BigQuery dataset created: Checkpoint Completed (1/5)'

# Create a model to predict visitor transaction
    if (bq query --use_legacy_sql=false \
    '#standardSQL
    CREATE OR REPLACE MODEL `bqml_lab.sample_model`
    OPTIONS(model_type="logistic_reg") AS
    SELECT
    IF(totals.transactions IS NULL, 0, 1) AS label,
    IFNULL(device.operatingSystem, "") AS os,
    device.isMobile AS is_mobile,
    IFNULL(geoNetwork.country, "") AS country,
    IFNULL(totals.pageviews, 0) AS pageviews
    FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    WHERE
    _TABLE_SUFFIX BETWEEN "20160801" AND "20170631"
    LIMIT 100000;')

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Visitor Transaction: Checkpoint Completed (2/5)'

# Evaluate the model
        if (bq query --use_legacy_sql=false \
        '#standardSQL
        SELECT
        *
        FROM
        ml.EVALUATE(MODEL `bqml_lab.sample_model`, (
        SELECT
        IF(totals.transactions IS NULL, 0, 1) AS label,
        IFNULL(device.operatingSystem, "") AS os,
        device.isMobile AS is_mobile,
        IFNULL(geoNetwork.country, "") AS country,
        IFNULL(totals.pageviews, 0) AS pageviews
        FROM
        `bigquery-public-data.google_analytics_sample.ga_sessions_*`
        WHERE
        _TABLE_SUFFIX BETWEEN "20170701" AND "20170801"));')

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Model Evaluated: Checkpoint Completed (3/5)'

# Predict purchases per country
            if (bq query --use_legacy_sql=false \
            '#standardSQL
            SELECT
            country,
            SUM(predicted_label) as total_predicted_purchases
            FROM
            ml.PREDICT(MODEL `bqml_lab.sample_model`, (
            SELECT
            IFNULL(device.operatingSystem, "") AS os,
            device.isMobile AS is_mobile,
            IFNULL(totals.pageviews, 0) AS pageviews,
            IFNULL(geoNetwork.country, "") AS country
            FROM
            `bigquery-public-data.google_analytics_sample.ga_sessions_*`
            WHERE
            _TABLE_SUFFIX BETWEEN "20170701" AND "20170801"))
            GROUP BY country
            ORDER BY total_predicted_purchases DESC
            LIMIT 10;')

            then
                printf "\n\e[1;96m%s\n\n\e[m" 'Purchases per country: Checkpoint Completed (4/5)'

# Predict purchases per user
                if (bq query --use_legacy_sql=false \
                '#standardSQL
                SELECT
                fullVisitorId,
                SUM(predicted_label) as total_predicted_purchases
                FROM
                ml.PREDICT(MODEL `bqml_lab.sample_model`, (
                SELECT
                IFNULL(device.operatingSystem, "") AS os,
                device.isMobile AS is_mobile,
                IFNULL(totals.pageviews, 0) AS pageviews,
                IFNULL(geoNetwork.country, "") AS country,
                fullVisitorId
                FROM
                `bigquery-public-data.google_analytics_sample.ga_sessions_*`
                WHERE
                _TABLE_SUFFIX BETWEEN "20170701" AND "20170801"))
                GROUP BY fullVisitorId
                ORDER BY total_predicted_purchases DESC
                LIMIT 10;')

                then
                    printf "\n\e[1;96m%s\n\n\e[m" 'Purchases per user: Checkpoint Completed (5/5)'
                fi
            fi
        fi
    fi
printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all