#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

# Create a training dataset

if (bq --location EU mk bike_model

bq query --nouse_legacy_sql \
'CREATE OR REPLACE MODEL
  bike_model.model
OPTIONS
  (input_label_cols=["duration"],
    model_type="linear_reg") AS
SELECT
  duration,
  start_station_name,
  CAST(EXTRACT(dayofweek
    FROM
      start_date) AS STRING) AS dayofweek,
  CAST(EXTRACT(hour
    FROM
      start_date) AS STRING) AS hourofday
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire
  WHERE `duration` IS NOT NULL;')

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Training Dataset: Checkpoint Completed (1/4)'

# Improving the model through feature engineering

    if (bq query --nouse_legacy_sql \
    'CREATE OR REPLACE MODEL
    bike_model.model_weekday
    OPTIONS
    (input_label_cols=["duration"],
        model_type="linear_reg") AS
    SELECT
    duration,
    start_station_name,
    IF
    (EXTRACT(dayofweek
        FROM
        start_date) BETWEEN 2 AND 6,
        "weekday",
        "weekend") AS dayofweek,
    CAST(EXTRACT(hour
        FROM
        start_date) AS STRING) AS hourofday
    FROM
    `bigquery-public-data`.london_bicycles.cycle_hire
    WHERE `duration` IS NOT NULL;'
    
    bq query --nouse_legacy_sql \
    'CREATE OR REPLACE MODEL
    bike_model.model_bucketized
    OPTIONS
    (input_label_cols=["duration"],
        model_type="linear_reg") AS
    SELECT
    duration,
    start_station_name,
    IF
    (EXTRACT(dayofweek
        FROM
        start_date) BETWEEN 2 AND 6,
        "weekday",
        "weekend") AS dayofweek,
    ML.BUCKETIZE(EXTRACT(hour
        FROM
        start_date),
        [5, 10, 17]) AS hourofday
    FROM
    `bigquery-public-data`.london_bicycles.cycle_hire
    WHERE `duration` IS NOT NULL;')

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Improving the model: Checkpoint Completed (2/4)'

# Make predictions

        if (bq query --nouse_legacy_sql \
        'CREATE OR REPLACE MODEL
        bike_model.model_bucketized TRANSFORM(* EXCEPT(start_date),
        IF
            (EXTRACT(dayofweek
            FROM
                start_date) BETWEEN 2 AND 6,
            "weekday",
            "weekend") AS dayofweek,
            ML.BUCKETIZE(EXTRACT(HOUR
            FROM
                start_date),
            [5, 10, 17]) AS hourofday )
        OPTIONS
        (input_label_cols=["duration"],
            model_type="linear_reg") AS
        SELECT
        duration,
        start_station_name,
        start_date
        FROM
        `bigquery-public-data`.london_bicycles.cycle_hire
        WHERE `duration` IS NOT NULL;'

        bq query --nouse_legacy_sql \
        'SELECT
        *
        FROM
        ML.PREDICT(MODEL bike_model.model_bucketized,
            (
            SELECT
            "Park Lane , Hyde Park" AS start_station_name,
            CURRENT_TIMESTAMP() AS start_date) );'

        bq query --nouse_legacy_sql \
        'SELECT
        *
        FROM
        ML.PREDICT(MODEL bike_model.model_bucketized,
            (
            SELECT
            start_station_name,
            start_date
            FROM
            `bigquery-public-data`.london_bicycles.cycle_hire
            LIMIT
            100) );')

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Predictions: Checkpoint Completed (3/4)'

# Examine model weights

            if (bq query --nouse_legacy_sql \
            'SELECT * FROM ML.WEIGHTS(MODEL bike_model.model_bucketized);')

            then
                printf "\n\e[1;96m%s\n\n\e[m" 'Examined Model Weights: Checkpoint Completed (4/4)'
            fi
        fi
    fi
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all