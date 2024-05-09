#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

# Minimize I/O

if (bq query --nouse_legacy_sql \
'WITH
  stations AS (
SELECT
  s.id AS start_id,
  e.id AS end_id,
  ST_Distance(ST_GeogPoint(s.longitude,
      s.latitude),
    ST_GeogPoint(e.longitude,
      e.latitude)) AS distance
FROM
  `bigquery-public-data`.london_bicycles.cycle_stations s,
  `bigquery-public-data`.london_bicycles.cycle_stations e ),
trip_distance AS (
SELECT
  bike_id,
  distance
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire,
  stations
WHERE
  start_station_id = start_id
  AND end_station_id = end_id )
SELECT
  bike_id,
  SUM(distance)/1000 AS total_distance
FROM
  trip_distance
GROUP BY
  bike_id
ORDER BY
  total_distance DESC
LIMIT
  5;')

then
    printf "\n\e[1;96m%s\n\n\e[m" 'I/O Minimized: Checkpoint Completed (1/6)'

# Cache results of previous queries

    if (bq --location EU mk mydataset

    bq query --nouse_legacy_sql \
    'WITH
    typical_trip AS (
    SELECT
    start_station_name,
    end_station_name,
    APPROX_QUANTILES(duration, 10)[OFFSET (5)] AS typical_duration,
    COUNT(duration) AS num_trips
    FROM
    `bigquery-public-data`.london_bicycles.cycle_hire
    GROUP BY
    start_station_name,
    end_station_name )
    SELECT
    EXTRACT (DATE
    FROM
        start_date) AS trip_date,
    APPROX_QUANTILES(duration / typical_duration, 10)[
    OFFSET
    (5)] AS ratio,
    COUNT(*) AS num_trips_on_day
    FROM
    `bigquery-public-data`.london_bicycles.cycle_hire AS hire
    JOIN
    typical_trip AS trip
    ON
    hire.start_station_name = trip.start_station_name
    AND hire.end_station_name = trip.end_station_name
    AND num_trips > 10
    GROUP BY
    trip_date
    HAVING
    num_trips_on_day > 10
    ORDER BY
    ratio DESC
    LIMIT
    10;')

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Cache Result: Checkpoint Completed (2/6)'

# Denormalization

        if (bq query --nouse_legacy_sql \
        'CREATE OR REPLACE TABLE
        mydataset.london_bicycles_denorm AS
        SELECT
        start_station_id,
        s.latitude AS start_latitude,
        s.longitude AS start_longitude,
        end_station_id,
        e.latitude AS end_latitude,
        e.longitude AS end_longitude
        FROM
        `bigquery-public-data`.london_bicycles.cycle_hire AS h
        JOIN
        `bigquery-public-data`.london_bicycles.cycle_stations AS s
        ON
        h.start_station_id = s.id
        JOIN
        `bigquery-public-data`.london_bicycles.cycle_stations AS e
        ON
        h.end_station_id = e.id;')

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Denormalization: Checkpoint Completed (3/6)'

# Joins

            if (bq query --nouse_legacy_sql \
            'WITH
            distances AS (
            SELECT
                a.id AS start_station_id,
                a.name AS start_station_name,
                b.id AS end_station_id,
                b.name AS end_station_name,
                ST_DISTANCE(ST_GeogPoint(a.longitude,
                    a.latitude),
                ST_GeogPoint(b.longitude,
                    b.latitude)) AS distance
            FROM
                `bigquery-public-data`.london_bicycles.cycle_stations a
            CROSS JOIN
                `bigquery-public-data`.london_bicycles.cycle_stations b
            WHERE
                a.id != b.id ),
            durations AS (
            SELECT
                start_station_id,
                end_station_id,
                AVG(duration) AS duration,
                COUNT(*) AS num_rides
            FROM
                `bigquery-public-data`.london_bicycles.cycle_hire
            WHERE
                duration > 0
            GROUP BY
                start_station_id,
                end_station_id
            HAVING
                num_rides > 100 )
            SELECT
            start_station_name,
            end_station_name,
            distance,
            duration,
            duration/distance AS pace
            FROM
            distances
            JOIN
            durations
            USING
            (start_station_id,
                end_station_id)
            ORDER BY
            pace ASC
            LIMIT
            5;')

            then
                printf "\n\e[1;96m%s\n\n\e[m" 'Joins: Checkpoint Completed (4/6)'

# Avoid overwhelming a worker

                if (bq query --nouse_legacy_sql \
                'WITH
                rentals_on_day AS (
                SELECT
                    rental_id,
                    end_date,
                    EXTRACT(DATE
                    FROM
                    end_date) AS rental_date
                FROM
                    `bigquery-public-data.london_bicycles.cycle_hire` )
                SELECT
                rental_id,
                rental_date,
                ROW_NUMBER() OVER(PARTITION BY rental_date ORDER BY end_date) AS rental_number_on_day
                FROM
                rentals_on_day
                ORDER BY
                rental_date ASC,
                rental_number_on_day ASC
                LIMIT
                5;')

                then
                    printf "\n\e[1;96m%s\n\n\e[m" 'Avoid overwhelming a worker: Checkpoint Completed (5/6)'

# Approximate aggregation functions

                    if (bq query --nouse_legacy_sql \
                    'SELECT
                    APPROX_COUNT_DISTINCT(repo_name) AS num_repos
                    FROM
                    `bigquery-public-data`.github_repos.commits,
                    UNNEST(repo_name) AS repo_name;')

                    then
                        printf "\n\e[1;96m%s\n\n\e[m" 'Approximate result: Checkpoint Completed (6/6)'
                    fi
                fi
            fi
        fi
    fi
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all