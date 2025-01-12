# **To be done using Google Cloud Shell**

**1. BQ Query most goals scored**

**2. BQ Query most attempted passes**

**3. BQ Query penalty kick success**

```sql
bq query --nouse_legacy_sql \
'SELECT
 date,
 label,
 (team1.score + team2.score) AS totalGoals
FROM
 `soccer.matches` Matches
LEFT JOIN
 `soccer.competitions` Competitions ON
   Matches.competitionId = Competitions.wyId
WHERE
 status = "Played" AND
 Competitions.name = "Spanish first division"
ORDER BY
 totalGoals DESC, date DESC'

bq query --nouse_legacy_sql \
'SELECT
 playerId,
 (Players.firstName || " " || Players.lastName) AS playerName,
 COUNT(id) AS numPasses
FROM
 `soccer.events` Events
LEFT JOIN
 `soccer.players` Players ON
   Events.playerId = Players.wyId
WHERE
 eventName = "Pass"
GROUP BY
 playerId, playerName
ORDER BY
 numPasses DESC
LIMIT 10'

bq query --nouse_legacy_sql \
'SELECT
 playerId,
 (Players.firstName || " " || Players.lastName) AS playerName,
 COUNT(id) AS numPKAtt,
 SUM(IF(101 IN UNNEST(tags.id), 1, 0)) AS numPKGoals,
 SAFE_DIVIDE(
   SUM(IF(101 IN UNNEST(tags.id), 1, 0)),
   COUNT(id)
   ) AS PKSuccessRate
FROM
 `soccer.events` Events
LEFT JOIN
 `soccer.players` Players ON
   Events.playerId = Players.wyId
WHERE
 eventName = "Free Kick" AND
 subEventName = "Penalty"
GROUP BY
 playerId, playerName
HAVING
 numPkAtt >= 5
ORDER BY
 PKSuccessRate DESC, numPKAtt DESC'
```

## Lab Completed🎉