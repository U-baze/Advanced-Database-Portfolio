-- 10 teams with 4 players each
INSERT INTO teams (team_name)
SELECT 'Team ' || lpad(g::text, 2, '0') FROM generate_series(1, 10) AS g;

INSERT INTO players (team_id, player_name)
SELECT t.team_id, t.team_name || ' Player ' || p
FROM teams t CROSS JOIN generate_series(1, 4) AS p;

-- Flags for the first 3 ticks; the event starts 21 Nov 2026 at 09:00 Lagos time
INSERT INTO flags (team_id, tick_no, flag_hash, created_at, expires_at)
SELECT t.team_id, k,
       encode(sha256(convert_to('AOT{' || t.team_id || '-' || k || '-' || md5(random()::text) || '}', 'UTF8')), 'hex'),
       TIMESTAMPTZ '2026-11-21 09:00+01' + (k - 1) * INTERVAL '5 minutes',
       TIMESTAMPTZ '2026-11-21 09:00+01' + (k - 1) * INTERVAL '5 minutes' + INTERVAL '15 minutes'
FROM teams t CROSS JOIN generate_series(1, 3) AS k;

-- One submission for each possible result
INSERT INTO submissions (team_id, player_id, flag_id, submitted_at, result) VALUES
 (1, (SELECT min(player_id) FROM players WHERE team_id = 1), (SELECT flag_id FROM flags WHERE team_id = 2 AND tick_no = 1), '2026-11-21 09:02+01', 'accepted'),
 (3, (SELECT min(player_id) FROM players WHERE team_id = 3), (SELECT flag_id FROM flags WHERE team_id = 2 AND tick_no = 1), '2026-11-21 09:03+01', 'accepted'),
 (1, (SELECT min(player_id) FROM players WHERE team_id = 1), (SELECT flag_id FROM flags WHERE team_id = 2 AND tick_no = 1), '2026-11-21 09:04+01', 'duplicate'),
 (2, (SELECT min(player_id) FROM players WHERE team_id = 2), (SELECT flag_id FROM flags WHERE team_id = 2 AND tick_no = 1), '2026-11-21 09:04+01', 'own_flag'),
 (4, (SELECT min(player_id) FROM players WHERE team_id = 4), NULL,                                                         '2026-11-21 09:06+01', 'invalid'),
 (5, (SELECT min(player_id) FROM players WHERE team_id = 5), (SELECT flag_id FROM flags WHERE team_id = 2 AND tick_no = 1), '2026-11-21 09:20+01', 'expired'),
 (1, (SELECT min(player_id) FROM players WHERE team_id = 1), (SELECT flag_id FROM flags WHERE team_id = 3 AND tick_no = 2), '2026-11-21 09:07+01', 'accepted');

SELECT 'teams' AS tbl, count(*) FROM teams
UNION ALL SELECT 'players', count(*) FROM players
UNION ALL SELECT 'flags', count(*) FROM flags
UNION ALL SELECT 'submissions', count(*) FROM submissions;
