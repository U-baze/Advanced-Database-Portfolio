-- Portfolio 3: COMMIT, ROLLBACK, automatic rollback on error, SAVEPOINT
SELECT (SELECT min(player_id) FROM players WHERE team_id = 1) AS player,
       (SELECT flag_id FROM flags WHERE team_id = 4 AND tick_no = 1) AS flag \gset

\echo '=== Starting point: Team 01 submissions'
SELECT result, count(*) FROM submissions WHERE team_id = 1 GROUP BY result ORDER BY result;

\echo '=== 1. COMMIT: Team 01 captures the tick-1 flag of Team 04'
BEGIN;
INSERT INTO submissions (team_id, player_id, flag_id, result) VALUES (1, :player, :flag, 'accepted');
COMMIT;
SELECT result, count(*) FROM submissions WHERE team_id = 1 GROUP BY result ORDER BY result;

\echo '=== 2. ROLLBACK by choice: a mistaken batch of 5 attempts is cancelled'
BEGIN;
INSERT INTO submissions (team_id, player_id, flag_id, result)
SELECT 1, :player, NULL, 'invalid' FROM generate_series(1, 5);
SELECT count(*) AS invalid_inside_transaction FROM submissions WHERE team_id = 1 AND result = 'invalid';
ROLLBACK;
SELECT count(*) AS invalid_after_rollback FROM submissions WHERE team_id = 1 AND result = 'invalid';

\echo '=== 3. Automatic rollback: one failing statement undoes the whole transaction'
BEGIN;
INSERT INTO submissions (team_id, player_id, flag_id, result) VALUES (1, :player, NULL, 'invalid');
INSERT INTO submissions (team_id, player_id, flag_id, result) VALUES (1, :player, :flag, 'accepted');
COMMIT;
SELECT count(*) AS invalid_after_failed_transaction FROM submissions WHERE team_id = 1 AND result = 'invalid';

\echo '=== 4. SAVEPOINT: a failed capture is kept on record as a duplicate'
BEGIN;
SAVEPOINT try_capture;
INSERT INTO submissions (team_id, player_id, flag_id, result) VALUES (1, :player, :flag, 'accepted');
ROLLBACK TO SAVEPOINT try_capture;
INSERT INTO submissions (team_id, player_id, flag_id, result) VALUES (1, :player, :flag, 'duplicate');
COMMIT;
SELECT result, count(*) FROM submissions WHERE team_id = 1 AND flag_id = :flag GROUP BY result ORDER BY result;
