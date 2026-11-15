-- Builds Redis commands that load each team's points into a sorted set
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
SELECT 'ZADD aotctf:leaderboard ' || coalesce(sum(p.pts), 0) || ' "' || t.team_name || '"'
FROM teams t LEFT JOIN pts p ON p.team_id = t.team_id
GROUP BY t.team_name
ORDER BY t.team_name;
