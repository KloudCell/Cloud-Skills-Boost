#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

# Calculate trips taken by Yellow taxi in each month of 2015

if (bq query --nouse_legacy_sql \
'SELECT
  TIMESTAMP_TRUNC(pickup_datetime,
    MONTH) month,
  COUNT(*) trips
FROM
  `bigquery-public-data.new_york.tlc_yellow_trips_2015`
GROUP BY
  1
ORDER BY
  1;')

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Trips taken by Yellow taxi: Checkpoint Completed (1/7)'

# Calculate average speed of Yellow taxi trips in 2015

    if (bq query --nouse_legacy_sql \
    'SELECT
    EXTRACT(HOUR
    FROM
        pickup_datetime) hour,
    ROUND(AVG(trip_distance / TIMESTAMP_DIFF(dropoff_datetime,
            pickup_datetime,
            SECOND))*3600, 1) speed
    FROM
    `bigquery-public-data.new_york.tlc_yellow_trips_2015`
    WHERE
    trip_distance > 0
    AND fare_amount/trip_distance BETWEEN 2
    AND 10
    AND dropoff_datetime > pickup_datetime
    GROUP BY
    1
    ORDER BY
    1;'
    )

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Average Speed of Yellow taxi: Checkpoint Completed (2/7)'

# Test whether fields are good inputs to your fare forecasting model

        if (bq query --nouse_legacy_sql \
        'WITH params AS (
            SELECT
            1 AS TRAIN,
            2 AS EVAL
            ),

        daynames AS
            (SELECT ["Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"] AS daysofweek),

        taxitrips AS (
        SELECT
            (tolls_amount + fare_amount) AS total_fare,
            daysofweek[ORDINAL(EXTRACT(DAYOFWEEK FROM pickup_datetime))] AS dayofweek,
            EXTRACT(HOUR FROM pickup_datetime) AS hourofday,
            pickup_longitude AS pickuplon,
            pickup_latitude AS pickuplat,
            dropoff_longitude AS dropofflon,
            dropoff_latitude AS dropofflat,
            passenger_count AS passengers
        FROM
            `nyc-tlc.yellow.trips`, daynames, params
        WHERE
            trip_distance > 0 AND fare_amount > 0
            AND MOD(ABS(FARM_FINGERPRINT(CAST(pickup_datetime AS STRING))),1000) = params.TRAIN
        )

        SELECT *
        FROM taxitrips;')

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Test Fields: Checkpoint Completed (3/7)'

# Create a BigQuery dataset to store models

            if (bq mk taxi)

            then
                printf "\n\e[1;96m%s\n\n\e[m" 'Bigquery Dataset: Checkpoint Completed (4/7)'

# Create a taxifare model

                if (bq query --nouse_legacy_sql \
                'CREATE or REPLACE MODEL taxi.taxifare_model
                OPTIONS
                (model_type="linear_reg", labels=["total_fare"]) AS

                WITH params AS (
                    SELECT
                    1 AS TRAIN,
                    2 AS EVAL
                    ),

                daynames AS
                    (SELECT ["Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"] AS daysofweek),

                taxitrips AS (
                SELECT
                    (tolls_amount + fare_amount) AS total_fare,
                    daysofweek[ORDINAL(EXTRACT(DAYOFWEEK FROM pickup_datetime))] AS dayofweek,
                    EXTRACT(HOUR FROM pickup_datetime) AS hourofday,
                    pickup_longitude AS pickuplon,
                    pickup_latitude AS pickuplat,
                    dropoff_longitude AS dropofflon,
                    dropoff_latitude AS dropofflat,
                    passenger_count AS passengers
                FROM
                    `nyc-tlc.yellow.trips`, daynames, params
                WHERE
                    trip_distance > 0 AND fare_amount > 0
                    AND MOD(ABS(FARM_FINGERPRINT(CAST(pickup_datetime AS STRING))),1000) = params.TRAIN
                )

                SELECT *
                FROM taxitrips;'
                )

                then
                    printf "\n\e[1;96m%s\n\n\e[m" 'Taxifare Model: Checkpoint Completed (5/7)'

# Evaluate classification model performance

                    if (bq query --nouse_legacy_sql \
                    'SELECT
                    SQRT(mean_squared_error) AS rmse
                    FROM
                    ML.EVALUATE(MODEL taxi.taxifare_model,
                    (

                    WITH params AS (
                        SELECT
                        1 AS TRAIN,
                        2 AS EVAL
                        ),

                    daynames AS
                        (SELECT ["Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"] AS daysofweek),

                    taxitrips AS (
                    SELECT
                        (tolls_amount + fare_amount) AS total_fare,
                        daysofweek[ORDINAL(EXTRACT(DAYOFWEEK FROM pickup_datetime))] AS dayofweek,
                        EXTRACT(HOUR FROM pickup_datetime) AS hourofday,
                        pickup_longitude AS pickuplon,
                        pickup_latitude AS pickuplat,
                        dropoff_longitude AS dropofflon,
                        dropoff_latitude AS dropofflat,
                        passenger_count AS passengers
                    FROM
                        `nyc-tlc.yellow.trips`, daynames, params
                    WHERE
                        trip_distance > 0 AND fare_amount > 0
                        AND MOD(ABS(FARM_FINGERPRINT(CAST(pickup_datetime AS STRING))),1000) = params.EVAL
                    )

                    SELECT *
                    FROM taxitrips

                    ));'
                    )

                    then
                        printf "\n\e[1;96m%s\n\n\e[m" 'Model Performance: Checkpoint Completed (6/7)'

# Predict taxi fare amount

                        if (bq query --nouse_legacy_sql \
                        'SELECT
                        *
                        FROM
                        ml.PREDICT(MODEL `taxi.taxifare_model`,
                        (

                        WITH params AS (
                            SELECT
                            1 AS TRAIN,
                            2 AS EVAL
                            ),

                        daynames AS
                            (SELECT ["Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"] AS daysofweek),

                        taxitrips AS (
                        SELECT
                            (tolls_amount + fare_amount) AS total_fare,
                            daysofweek[ORDINAL(EXTRACT(DAYOFWEEK FROM pickup_datetime))] AS dayofweek,
                            EXTRACT(HOUR FROM pickup_datetime) AS hourofday,
                            pickup_longitude AS pickuplon,
                            pickup_latitude AS pickuplat,
                            dropoff_longitude AS dropofflon,
                            dropoff_latitude AS dropofflat,
                            passenger_count AS passengers
                        FROM
                            `nyc-tlc.yellow.trips`, daynames, params
                        WHERE
                            trip_distance > 0 AND fare_amount > 0
                            AND MOD(ABS(FARM_FINGERPRINT(CAST(pickup_datetime AS STRING))),1000) = params.EVAL
                        )

                        SELECT *
                        FROM taxitrips

                        ));')

                        then
                            printf "\n\e[1;96m%s\n\n\e[m" 'Taxi Fare: Checkpoint Completed (7/7)'
                        fi
                    fi
                fi
            fi
        fi
    fi
printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'
fi

gcloud auth revoke --all