SET TIME ZONE 'Africa/Lagos';
\echo 'Q1. Scoreboard: +1 per flag captured, -1 per flag lost'
WITH caps AS (
  SELECT s.team_id AS attacker, f.team_id AS victim
  FROM submissions s JOIN flags f ON f.flag_id = s.flag_id
  WHERE s.result = 'accepted'
),
pts AS (
  SELECT attacker AS team_id, 1 AS pts FROM caps
  UNION ALL
  SELECT victim, -1 FROM caps
)
SELECT RANK() OVER (ORDER BY coalesce(sum(p.pts), 0) DESC) AS rank,
       t.team_name,
       count(*) FILTER (WHERE p.pts = 1)  AS captured,
       count(*) FILTER (WHERE p.pts = -1) AS lost,
       coalesce(sum(p.pts), 0)            AS points
FROM teams t LEFT JOIN pts p ON p.team_id = t.team_id
GROUP BY t.team_id, t.team_name
ORDER BY points DESC;

\echo 'Q2. Captures per hour for each team, with a running total'
SELECT date_trunc('hour', s.submitted_at) AS hour,
       t.team_name,
       count(*) AS captures,
       sum(count(*)) OVER (PARTITION BY t.team_name ORDER BY date_trunc('hour', s.submitted_at)) AS running_total
FROM submissions s JOIN teams t ON t.team_id = s.team_id
WHERE s.result = 'accepted'
GROUP BY 1, 2
ORDER BY 1, 4 DESC;

\echo 'Q3. Most-attacked teams'
SELECT t.team_name AS victim,
       count(*) AS flags_lost,
       count(DISTINCT s.team_id) AS attacking_teams
FROM submissions s
JOIN flags f ON f.flag_id = s.flag_id
JOIN teams t ON t.team_id = f.team_id
WHERE s.result = 'accepted'
GROUP BY t.team_name
ORDER BY flags_lost DESC;

\echo 'Q4. Noisiest attackers in one tick (12:00-12:05)'
SELECT t.team_name,
       count(*) AS attempts,
       count(*) FILTER (WHERE s.result = 'invalid')   AS invalid,
       count(*) FILTER (WHERE s.result = 'duplicate') AS duplicates
FROM submissions s JOIN teams t ON t.team_id = s.team_id
WHERE s.submitted_at >= '2026-11-21 12:00+01'
  AND s.submitted_at <  '2026-11-21 12:05+01'
GROUP BY t.team_name
ORDER BY attempts DESC;
