-- Portfolio 2: a full 8-hour AOT-CTF event
-- Keeps the 10 teams and 40 players; rebuilds flags and submissions.
DROP INDEX IF EXISTS idx_submissions_time, idx_submissions_accepted_time;
TRUNCATE submissions, flags RESTART IDENTITY;

-- 10 teams x 96 ticks = 960 flags; the event starts 21 Nov 2026 at 09:00 Lagos time
INSERT INTO flags (team_id, tick_no, flag_hash, created_at, expires_at)
SELECT t.team_id, k,
       encode(sha256(convert_to('AOT{' || t.team_id || '-' || k || '-' || md5(random()::text) || '}', 'UTF8')), 'hex'),
       TIMESTAMPTZ '2026-11-21 09:00+01' + (k - 1) * INTERVAL '5 minutes',
       TIMESTAMPTZ '2026-11-21 09:00+01' + (k - 1) * INTERVAL '5 minutes' + INTERVAL '15 minutes'
FROM teams t CROSS JOIN generate_series(1, 96) AS k;

-- 200,000 attempts.
-- Lower-numbered teams attack more; higher-numbered teams are attacked more.
-- Each team patches its service at a set tick: Team 01 at tick 5, rising by
-- 9 ticks per team to Team 10 at tick 86. After that, attacks on its flags
-- fail and the bots submit wrong values (recorded as invalid).
-- About 10% of attempts are made-up flags. Real flags are submitted up to
-- 20 minutes after planting, so some arrive after they expire.
WITH team_players AS (
  SELECT team_id, array_agg(player_id ORDER BY player_id) AS ids
  FROM players GROUP BY team_id
),
raw AS (
  SELECT g.*, g.tick >= 5 + (g.victim - 1) * 9 AS patched
  FROM (
    SELECT 1 + floor(power(random(), 1.5) * 10)::int AS attacker,
           10 - floor(power(random(), 2) * 10)::int  AS victim,
           1 + floor(random() * 96)::int             AS tick,
           random() < 0.10                            AS made_up,
           random()                                   AS r1,
           random()                                   AS r2
    FROM generate_series(1, 200000)
  ) g
),
attempts AS (
  SELECT r.attacker AS team_id,
         tp.ids[1 + floor(r.r1 * 4)::int] AS player_id,
         CASE WHEN r.made_up OR (r.patched AND r.attacker <> r.victim)
              THEN NULL ELSE f.flag_id END AS flag_id,
         CASE WHEN r.made_up
              THEN TIMESTAMPTZ '2026-11-21 09:00+01' + r.r2 * INTERVAL '8 hours'
              ELSE f.created_at + r.r2 * INTERVAL '20 minutes' END AS submitted_at,
         f.team_id AS owner_id,
         f.expires_at
  FROM raw r
  JOIN flags f ON f.team_id = r.victim AND f.tick_no = r.tick
  JOIN team_players tp ON tp.team_id = r.attacker
)
INSERT INTO submissions (team_id, player_id, flag_id, submitted_at, result)
SELECT team_id, player_id, flag_id, submitted_at,
       CASE
         WHEN flag_id IS NULL           THEN 'invalid'
         WHEN owner_id = team_id        THEN 'own_flag'
         WHEN submitted_at > expires_at THEN 'expired'
         WHEN row_number() OVER (
                PARTITION BY team_id, flag_id,
                             (flag_id IS NOT NULL AND owner_id <> team_id AND submitted_at <= expires_at)
                ORDER BY submitted_at) = 1 THEN 'accepted'
         ELSE 'duplicate'
       END
FROM attempts
ORDER BY submitted_at;

VACUUM ANALYZE flags;
VACUUM ANALYZE submissions;

SELECT result, count(*) FROM submissions GROUP BY result ORDER BY count(*) DESC;
