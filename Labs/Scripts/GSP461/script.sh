#! /bin/bash

wget https://raw.githubusercontent.com/KloudCell/Cloud-Skills-Boost/main/resources/welcome.sh 2> /dev/null
. welcome.sh

# Initialization
gcloud init --skip-diagnostics

# Write a query to determine available seasons and games
if (bq query --nouse_legacy_sql \
 'SELECT
  season,
  COUNT(*) as games_per_tournament
  FROM
 `bigquery-public-data.ncaa_basketball.mbb_historical_tournament_games`
  GROUP BY season
  ORDER BY season')

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Available Seasons and Games: Checkpoint Completed (1/8)'
fi

# Create a labeled machine learning dataset
if (bq query --nouse_legacy_sql \
'SELECT
  season, 
  round,
  days_from_epoch,
  game_date,
  day,
  "win" AS label,
  win_seed AS seed,
  win_market AS market,
  win_name AS name,
  win_alias AS alias,
  win_school_ncaa AS school_ncaa,
  lose_seed AS opponent_seed,
  lose_market AS opponent_market,
  lose_name AS opponent_name,
  lose_alias AS opponent_alias,
  lose_school_ncaa AS opponent_school_ncaa
FROM `bigquery-public-data.ncaa_basketball.mbb_historical_tournament_games`
UNION ALL
SELECT
  season,
  round,
  days_from_epoch,
  game_date,
  day,
  "loss" AS label, 
  lose_seed AS seed, 
  lose_market AS market,
  lose_name AS name,
  lose_alias AS alias,
  lose_school_ncaa AS school_ncaa,
  win_seed AS opponent_seed,
  win_market AS opponent_market,
  win_name AS opponent_name,
  win_alias AS opponent_alias,
  win_school_ncaa AS opponent_school_ncaa
FROM
`bigquery-public-data.ncaa_basketball.mbb_historical_tournament_games`'
)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Labeled machine learning dataset: Checkpoint Completed (2/8)'
fi

# Create a machine learning model to predict the winner based on seed and team name
if (bq mk bracketology &&\

bq query --nouse_legacy_sql \
'CREATE OR REPLACE MODEL
  `bracketology.ncaa_model`
OPTIONS
  ( model_type="logistic_reg") AS
SELECT
  season,
  "win" AS label,
  win_seed AS seed, 
  win_school_ncaa AS school_ncaa,
  lose_seed AS opponent_seed, 
  lose_school_ncaa AS opponent_school_ncaa
FROM `bigquery-public-data.ncaa_basketball.mbb_historical_tournament_games`
WHERE season <= 2017
UNION ALL
SELECT
  season,
  "loss" AS label,
  lose_seed AS seed,
  lose_school_ncaa AS school_ncaa,
  win_seed AS opponent_seed,
  win_school_ncaa AS opponent_school_ncaa
FROM
`bigquery-public-data.ncaa_basketball.mbb_historical_tournament_games`
WHERE season <= 2017' &&\

bq query --nouse_legacy_sql \
'SELECT
  category,
  weight
FROM
  UNNEST((
    SELECT
      category_weights
    FROM
      ML.WEIGHTS(MODEL `bracketology.ncaa_model`)
    WHERE
      processed_input = "seed")) 
      ORDER BY weight DESC')

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Machine learning model: Checkpoint Completed (3/8)'
fi

# Making predictions
if (bq query --nouse_legacy_sql \
'SELECT
  *
FROM
  ML.EVALUATE(MODEL   `bracketology.ncaa_model`)' &&\

bq query --nouse_legacy_sql \
'CREATE OR REPLACE TABLE `bracketology.predictions` AS (
SELECT * FROM ML.PREDICT(MODEL `bracketology.ncaa_model`,
(SELECT * FROM `data-to-insights.ncaa.2018_tournament_results`)
)
)')

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Evaluate model performance and create table: Checkpoint Completed  (4/8)'
fi

# Create a new ML dataset with these skillful features

if (bq query --nouse_legacy_sql \
'CREATE OR REPLACE TABLE `bracketology.training_new_features` AS
WITH outcomes AS (
SELECT
  season, 
  "win" AS label, 
  win_seed AS seed, 
  win_school_ncaa AS school_ncaa,
  lose_seed AS opponent_seed, 
  lose_school_ncaa AS opponent_school_ncaa
FROM `bigquery-public-data.ncaa_basketball.mbb_historical_tournament_games` t
WHERE season >= 2014
UNION ALL
SELECT
  season, 
  "loss" AS label, 
  lose_seed AS seed, 
  lose_school_ncaa AS school_ncaa,
  win_seed AS opponent_seed, 
  win_school_ncaa AS opponent_school_ncaa
FROM
`bigquery-public-data.ncaa_basketball.mbb_historical_tournament_games` t
WHERE season >= 2014
UNION ALL
SELECT
  season,
  label,
  seed,
  school_ncaa,
  opponent_seed,
  opponent_school_ncaa
FROM
  `data-to-insights.ncaa.2018_tournament_results`
)
SELECT
o.season,
label,
  seed,
  school_ncaa,
  team.pace_rank,
  team.poss_40min,
  team.pace_rating,
  team.efficiency_rank,
  team.pts_100poss,
  team.efficiency_rating,
  opponent_seed,
  opponent_school_ncaa,
  opp.pace_rank AS opp_pace_rank,
  opp.poss_40min AS opp_poss_40min,
  opp.pace_rating AS opp_pace_rating,
  opp.efficiency_rank AS opp_efficiency_rank,
  opp.pts_100poss AS opp_pts_100poss,
  opp.efficiency_rating AS opp_efficiency_rating,
  opp.pace_rank - team.pace_rank AS pace_rank_diff,
  opp.poss_40min - team.poss_40min AS pace_stat_diff,
  opp.pace_rating - team.pace_rating AS pace_rating_diff,
  opp.efficiency_rank - team.efficiency_rank AS eff_rank_diff,
  opp.pts_100poss - team.pts_100poss AS eff_stat_diff,
  opp.efficiency_rating - team.efficiency_rating AS eff_rating_diff
FROM outcomes AS o
LEFT JOIN `data-to-insights.ncaa.feature_engineering` AS team
ON o.school_ncaa = team.team AND o.season = team.season
LEFT JOIN `data-to-insights.ncaa.feature_engineering` AS opp
ON o.opponent_school_ncaa = opp.team AND o.season = opp.season'
)

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Using skillful ML model features: Checkpoint Completed (5/8)'
fi

# Train the new model
if (bq query --nouse_legacy_sql \
'CREATE OR REPLACE MODEL `bracketology.ncaa_model_updated`
OPTIONS(model_type="logistic_reg") AS
SELECT
  season,
  label,
  poss_40min,
  pace_rank,
  pace_rating,
  opp_poss_40min,
  opp_pace_rank,
  opp_pace_rating,
  pace_rank_diff,
  pace_stat_diff,
  pace_rating_diff,
  pts_100poss,
  efficiency_rank,
  efficiency_rating,
  opp_pts_100poss,
  opp_efficiency_rank,
  opp_efficiency_rating,
  eff_rank_diff,
  eff_stat_diff,
  eff_rating_diff
FROM `bracketology.training_new_features`
WHERE season BETWEEN 2014 AND 2017;

SELECT
  *
FROM
  ML.EVALUATE(MODEL `bracketology.ncaa_model_updated`);')

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Trained the new model and made evaluation: Checkpoint Completed (6/8)'
fi

# Prediction time!
if (bq query --nouse_legacy_sql \
'CREATE OR REPLACE TABLE `bracketology.ncaa_2018_predictions` AS
SELECT
  *
FROM
  ML.PREDICT(MODEL `bracketology.ncaa_model_updated`, 
    (
      SELECT
        *
      FROM `bracketology.training_new_features`
      WHERE season = 2018
    )
  )')

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Created table ncaa_2018_predictions: Checkpoint Completed (7/8)'
fi

# Predicting for the 2019 March Madness tournament
if (bq query --nouse_legacy_sql \
'SELECT
CONCAT(school_ncaa, " was predicted to ",IF(predicted_label="loss","lose","win")," ",CAST(ROUND(p.prob,2)*100 AS STRING), "% but ", IF(n.label="loss","lost","won")) AS narrative,
predicted_label, 
n.label, 
ROUND(p.prob,2) AS probability,
season,
seed,
school_ncaa,
pace_rank,
efficiency_rank,
opponent_seed,
opponent_school_ncaa,
opp_pace_rank,
opp_efficiency_rank
FROM `bracketology.ncaa_2018_predictions` AS n,
UNNEST(predicted_label_probs) AS p
WHERE
  predicted_label <> n.label 
  AND p.prob > .75 
ORDER BY prob DESC' &&\

bq query --nouse_legacy_sql \
'SELECT
CONCAT(opponent_school_ncaa, " (", opponent_seed, ") was ",CAST(ROUND(ROUND(p.prob,2)*100,2) AS STRING),"% predicted to upset ", school_ncaa, " (", seed, ") and did!") AS narrative,
predicted_label, 
n.label, 
ROUND(p.prob,2) AS probability,
season,
seed,
school_ncaa,
pace_rank,
efficiency_rank,
opponent_seed,
opponent_school_ncaa,
opp_pace_rank,
opp_efficiency_rank,
(CAST(opponent_seed AS INT64) - CAST(seed AS INT64)) AS seed_diff
FROM `bracketology.ncaa_2018_predictions` AS n,
UNNEST(predicted_label_probs) AS p
WHERE
  predicted_label = "loss"
  AND predicted_label = n.label 
  AND p.prob >= .55  
  AND (CAST(opponent_seed AS INT64) - CAST(seed AS INT64)) > 2' &&\
  
bq query --nouse_legacy_sql \
'SELECT
  NULL AS label,
  team.school_ncaa AS team_school_ncaa,
  team.seed AS team_seed,
  opp.school_ncaa AS opp_school_ncaa,
  opp.seed AS opp_seed
FROM `data-to-insights.ncaa.2019_tournament_seeds` AS team
CROSS JOIN `data-to-insights.ncaa.2019_tournament_seeds` AS opp
WHERE team.school_ncaa <> opp.school_ncaa' &&\

bq query --nouse_legacy_sql \
'CREATE OR REPLACE TABLE `bracketology.ncaa_2019_tournament` AS
WITH team_seeds_all_possible_games AS (
  SELECT
    NULL AS label,
    team.school_ncaa AS school_ncaa,
    team.seed AS seed,
    opp.school_ncaa AS opponent_school_ncaa,
    opp.seed AS opponent_seed
  FROM `data-to-insights.ncaa.2019_tournament_seeds` AS team
  CROSS JOIN `data-to-insights.ncaa.2019_tournament_seeds` AS opp
  WHERE team.school_ncaa <> opp.school_ncaa
)
, add_in_2018_season_stats AS (
SELECT
  team_seeds_all_possible_games.*,
  (SELECT AS STRUCT * FROM `data-to-insights.ncaa.feature_engineering` WHERE school_ncaa = team AND season = 2018) AS team,
  (SELECT AS STRUCT * FROM `data-to-insights.ncaa.feature_engineering` WHERE opponent_school_ncaa = team AND season = 2018) AS opp
FROM team_seeds_all_possible_games
)
SELECT
  label,
  2019 AS season,
  seed,
  school_ncaa,
  team.pace_rank,
  team.poss_40min,
  team.pace_rating,
  team.efficiency_rank,
  team.pts_100poss,
  team.efficiency_rating,
  opponent_seed,
  opponent_school_ncaa,
  opp.pace_rank AS opp_pace_rank,
  opp.poss_40min AS opp_poss_40min,
  opp.pace_rating AS opp_pace_rating,
  opp.efficiency_rank AS opp_efficiency_rank,
  opp.pts_100poss AS opp_pts_100poss,
  opp.efficiency_rating AS opp_efficiency_rating,
  opp.pace_rank - team.pace_rank AS pace_rank_diff,
  opp.poss_40min - team.poss_40min AS pace_stat_diff,
  opp.pace_rating - team.pace_rating AS pace_rating_diff,
  opp.efficiency_rank - team.efficiency_rank AS eff_rank_diff,
  opp.pts_100poss - team.pts_100poss AS eff_stat_diff,
  opp.efficiency_rating - team.efficiency_rating AS eff_rating_diff
FROM add_in_2018_season_stats' &&\

bq query --nouse_legacy_sql \
'CREATE OR REPLACE TABLE `bracketology.ncaa_2019_tournament_predictions` AS
SELECT
  *
FROM
  ML.PREDICT(MODEL     `bracketology.ncaa_model_updated`, 
(
SELECT * FROM `bracketology.ncaa_2019_tournament`
))')

then
    printf "\n\e[1;96m%s\n\n\e[m" 'Created table ncaa_2019_tournament and ncaa_2019_tournament_predictions: Checkpoint Completed (8/8)'
fi

printf "\n\e[1;92m%s\n\n\e[m" 'Lab Completed'

gcloud auth revoke --all