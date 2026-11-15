SET TIME ZONE 'Africa/Lagos';

\echo '===== Q2 plan: captures per hour ====='
EXPLAIN (ANALYZE, BUFFERS)
SELECT date_trunc('hour', s.submitted_at) AS hour, t.team_name, count(*) AS captures
FROM submissions s JOIN teams t ON t.team_id = s.team_id
WHERE s.result = 'accepted'
GROUP BY 1, 2;

\echo '===== Q4 plan: noisiest attackers in one tick ====='
EXPLAIN (ANALYZE, BUFFERS)
SELECT t.team_name, count(*) AS attempts
FROM submissions s JOIN teams t ON t.team_id = s.team_id
WHERE s.submitted_at >= '2026-11-21 12:00+01'
  AND s.submitted_at <  '2026-11-21 12:05+01'
GROUP BY t.team_name;
