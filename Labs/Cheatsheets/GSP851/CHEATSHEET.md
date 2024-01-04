# **To be execute in Google Cloud Shell**

**1. BQ Query calculate shot distance**

    bq query --nouse_legacy_sql \
    'CREATE FUNCTION `soccer.GetShotDistanceToGoal`(x INT64, y INT64)
    RETURNS FLOAT64
    AS (
    /* Translate 0-100 (x,y) coordinate-based distances to absolute positions
    using "average" field dimensions of 105x68 before combining in 2D dist calc */
    SQRT(
    POW((100 - x) * 105/100, 2) +
    POW((50 - y) * 68/100, 2)
    )
    );'

**2.  BQ Query calculate shot angle**

    bq query --nouse_legacy_sql \
    'CREATE FUNCTION `soccer.GetShotAngleToGoal`(x INT64, y INT64)
    RETURNS FLOAT64
    AS (
    SAFE.ACOS(
        SAFE_DIVIDE(
        (POW(105 - (x * 105/100), 2) + POW(34 + (7.32/2) - (y * 68/100), 2)) +
        (POW(105 - (x * 105/100), 2) + POW(34 - (7.32/2) - (y * 68/100), 2)) -
        POW(7.32, 2),
        (2 *
        SQRT(POW(105 - (x * 105/100), 2) + POW(34 + 7.32/2 - (y * 68/100), 2)) *
        SQRT(POW(105 - (x * 105/100), 2) + POW(34 - 7.32/2 - (y * 68/100), 2)))
        )
    ) * 180 / ACOS(-1)
    );'

**3.  BQ Query expected goal with ML**

    bq query --nouse_legacy_sql \
    'CREATE MODEL `soccer.xg_logistic_reg_model`
    OPTIONS(
    model_type = "LOGISTIC_REG",
    input_label_cols = ["isGoal"]
    ) AS
    SELECT
    Events.subEventName AS shotType,
    (101 IN UNNEST(Events.tags.id)) AS isGoal,
    `soccer.GetShotDistanceToGoal`(Events.positions[ORDINAL(1)].x, Events.positions[ORDINAL(1)].y) AS shotDistance,
    `soccer.GetShotAngleToGoal`(Events.positions[ORDINAL(1)].x, Events.positions[ORDINAL(1)].y) AS shotAngle
    FROM
    `soccer.events` Events
    LEFT JOIN
    `soccer.matches` Matches ON Events.matchId = Matches.wyId
    LEFT JOIN
    `soccer.competitions` Competitions ON Matches.competitionId = Competitions.wyId
    WHERE
    Competitions.name != "World Cup"
    AND (eventName = "Shot" OR (eventName = "Free Kick" AND subEventName IN ("Free kick shot", "Penalty")))
    ;'

**4.  BQ Query model for expected goals**

    bq query --nouse_legacy_sql \
    'SELECT * FROM ML.WEIGHTS(MODEL soccer.xg_logistic_reg_model);'

    bq query --nouse_legacy_sql \
    'CREATE MODEL `soccer.xg_boosted_tree_model`
    OPTIONS(
    model_type = "BOOSTED_TREE_CLASSIFIER",
    input_label_cols = ["isGoal"]
    ) AS
    SELECT
    Events.subEventName AS shotType,
    (101 IN UNNEST(Events.tags.id)) AS isGoal,
    `soccer.GetShotDistanceToGoal`(Events.positions[ORDINAL(1)].x, Events.positions[ORDINAL(1)].y) AS shotDistance,
    `soccer.GetShotAngleToGoal`(Events.positions[ORDINAL(1)].x, Events.positions[ORDINAL(1)].y) AS shotAngle
    FROM
    `soccer.events` Events
    LEFT JOIN
    `soccer.matches` Matches ON Events.matchId = Matches.wyId
    LEFT JOIN
    `soccer.competitions` Competitions ON Matches.competitionId = Competitions.wyId
    WHERE
    Competitions.name != "World Cup"
    AND (eventName = "Shot" OR (eventName = "Free Kick" AND subEventName IN ("Free kick shot", "Penalty")));'

**5.  BQ Query model unlikely goals**

    bq query --nouse_legacy_sql '
    SELECT *
    FROM ML.PREDICT(MODEL `soccer.xg_logistic_reg_model`,
    (
    SELECT
        Events.subEventName AS shotType,
        (101 IN UNNEST(Events.tags.id)) AS isGoal,
        `soccer.GetShotDistanceToGoal`(Events.positions[ORDINAL(1)].x, Events.positions[ORDINAL(1)].y) AS shotDistance,
        `soccer.GetShotAngleToGoal`(Events.positions[ORDINAL(1)].x, Events.positions[ORDINAL(1)].y) AS shotAngle
    FROM
        `soccer.events` Events
    LEFT JOIN
        `soccer.matches` Matches ON Events.matchId = Matches.wyId
    LEFT JOIN
        `soccer.competitions` Competitions ON Matches.competitionId = Competitions.wyId
    WHERE
        Competitions.name = "World Cup" AND
        (eventName = "Shot" OR (eventName = "Free Kick" AND subEventName IN ("Free kick shot", "Penalty")))
    )
    )'

    bq query --nouse_legacy_sql '
    SELECT
    predicted_isGoal_probs[ORDINAL(1)].prob AS predictedGoalProb,
    * EXCEPT(predicted_isGoal, predicted_isGoal_probs)
    FROM ML.PREDICT(MODEL `soccer.xg_logistic_reg_model`,
    (
    SELECT
        Events.playerId,
        CONCAT(Players.firstName, " ", Players.lastName) AS playerName,
        Teams.name AS teamName,
        CAST(Matches.dateutc AS DATE) AS matchDate,
        Matches.label AS match,
        CAST(
        (CASE
            WHEN Events.matchPeriod = "1H" THEN 0
            WHEN Events.matchPeriod = "2H" THEN 45
            WHEN Events.matchPeriod = "E1" THEN 90
            WHEN Events.matchPeriod = "E2" THEN 105
            ELSE 120
        END) +
        CEILING(Events.eventSec / 60) AS INT64
        ) AS matchMinute,
        Events.subEventName AS shotType,
        (101 IN UNNEST(Events.tags.id)) AS isGoal,
        `soccer.GetShotDistanceToGoal`(Events.positions[ORDINAL(1)].x, Events.positions[ORDINAL(1)].y) AS shotDistance,
        `soccer.GetShotAngleToGoal`(Events.positions[ORDINAL(1)].x, Events.positions[ORDINAL(1)].y) AS shotAngle
    FROM
        `soccer.events` Events
    LEFT JOIN
        `soccer.matches` Matches ON Events.matchId = Matches.wyId
    LEFT JOIN
        `soccer.competitions` Competitions ON Matches.competitionId = Competitions.wyId
    LEFT JOIN
        `soccer.players` Players ON Events.playerId = Players.wyId
    LEFT JOIN
        `soccer.teams` Teams ON Events.teamId = Teams.wyId
    WHERE
        Competitions.name = "World"
    ))'

## Lab Completed🎉