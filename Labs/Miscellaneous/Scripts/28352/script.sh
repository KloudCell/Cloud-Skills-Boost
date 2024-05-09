#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

# Get MovieLens Data

if (bq --location EU mk --dataset movies

bq load --source_format=CSV \
 --location=EU \
 --autodetect movies.movielens_ratings \
gs://dataeng-movielens/ratings.csv

 bq load --source_format=CSV \
 --location=EU   \
 --autodetect movies.movielens_movies_raw \
 gs://dataeng-movielens/movies.csv)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'MovieLens Data: Checkpoint Completed (1/4)'

# Explore the Data

    if (bq query --nouse_legacy_sql \
    'CREATE OR REPLACE TABLE
    movies.movielens_movies AS
    SELECT
    * REPLACE(SPLIT(genres, "|") AS genres)
    FROM
    movies.movielens_movies_raw;')

    then
        printf "\n\e[1;96m%s\n\n\e[m" 'Explore the Data: Checkpoint Completed (2/4)'

# Making Recommendations

        if (bq query --nouse_legacy_sql \
        'SELECT
        *
        FROM
        ML.PREDICT(MODEL `cloud-training-prod-bucket.movies.movie_recommender`,
            (
            WITH
            seen AS (
            SELECT
                ARRAY_AGG(movieId) AS movies
            FROM
                movies.movielens_ratings
            WHERE
                userId = 903 )
            SELECT
            movieId,
            title,
            903 AS userId
            FROM
            movies.movielens_movies,
            UNNEST(genres) g,
            seen
            WHERE
            g = "Comedy"
            AND movieId NOT IN UNNEST(seen.movies) ))
        ORDER BY
        predicted_rating DESC
        LIMIT
        5;')

        then
            printf "\n\e[1;96m%s\n\n\e[m" 'Recommendations: Checkpoint Completed (3/4)'

# Customer Targeting

            if (bq query --nouse_legacy_sql \
            'SELECT
            *
            FROM
            ML.PREDICT(MODEL `cloud-training-prod-bucket.movies.movie_recommender`,
            (
            WITH
                allUsers AS (
                SELECT
                DISTINCT userId
                FROM
                movies.movielens_ratings )
            SELECT
                96481 AS movieId,
                (
                SELECT
                title
                FROM
                movies.movielens_movies
                WHERE
                movieId=96481) title,
                userId
            FROM
                allUsers ))
            ORDER BY
            predicted_rating DESC
            LIMIT
            100;')

            then
                printf "\n\e[1;96m%s\n\n\e[m" '100 Users: Checkpoint Completed (4/4)'
            fi
        fi
    fi
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all