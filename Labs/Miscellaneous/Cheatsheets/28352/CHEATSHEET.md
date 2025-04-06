# **To be done using Google Cloud Shell**

**1. Get MovieLens Data**

**2. Explore the Data**

**3. Making Recommendations**

**4. Customer Targeting**

```bash
bq --location EU mk --dataset movies

bq load --source_format=CSV \
 --location=EU \
 --autodetect movies.movielens_ratings \
gs://dataeng-movielens/ratings.csv

 bq load --source_format=CSV \
 --location=EU   \
 --autodetect movies.movielens_movies_raw \
 gs://dataeng-movielens/movies.csv

bq query --nouse_legacy_sql \
'CREATE OR REPLACE TABLE
  movies.movielens_movies AS
SELECT
  * REPLACE(SPLIT(genres, "|") AS genres)
FROM
  movies.movielens_movies_raw;'

bq query --nouse_legacy_sql \
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
  5;'

bq query --nouse_legacy_sql \
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
100;'
```

## Lab Completed🎉