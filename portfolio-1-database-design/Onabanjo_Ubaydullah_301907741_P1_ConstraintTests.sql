-- Every statement below breaks a rule and MUST fail
\warn '1. Duplicate team name (expect: unique violation)'
INSERT INTO teams (team_name) VALUES ('Team 01');

\warn '2. Tick outside 1 to 96 (expect: check violation)'
INSERT INTO flags (team_id, tick_no, flag_hash, created_at, expires_at)
VALUES (1, 97, repeat('a', 64), now(), now() + INTERVAL '15 minutes');

\warn '3. Second flag for the same team and tick (expect: unique violation)'
INSERT INTO flags (team_id, tick_no, flag_hash, created_at, expires_at)
VALUES (1, 1, repeat('b', 64), now(), now() + INTERVAL '15 minutes');

\warn '4. Flag that expires before it is created (expect: check violation)'
INSERT INTO flags (team_id, tick_no, flag_hash, created_at, expires_at)
VALUES (1, 50, repeat('c', 64), now(), now() - INTERVAL '1 minute');

\warn '5. Unknown result value (expect: check violation)'
INSERT INTO submissions (team_id, player_id, flag_id, result)
VALUES (1, (SELECT min(player_id) FROM players WHERE team_id = 1), (SELECT flag_id FROM flags WHERE team_id = 4 AND tick_no = 2), 'won');

\warn '6. Player submitting for a team they are not on (expect: foreign key violation)'
INSERT INTO submissions (team_id, player_id, flag_id, result)
VALUES (1, (SELECT min(player_id) FROM players WHERE team_id = 2),
        (SELECT flag_id FROM flags WHERE team_id = 4 AND tick_no = 1), 'accepted');

\warn '7. Same team capturing the same flag twice (expect: unique violation)'
INSERT INTO submissions (team_id, player_id, flag_id, result)
VALUES (1, (SELECT max(player_id) FROM players WHERE team_id = 1),
        (SELECT flag_id FROM flags WHERE team_id = 2 AND tick_no = 1), 'accepted');

\warn '8. Accepted submission with no flag (expect: check violation)'
INSERT INTO submissions (team_id, player_id, flag_id, result)
VALUES (1, (SELECT min(player_id) FROM players WHERE team_id = 1), NULL, 'accepted');

\warn 'Submissions should still number 7:'
SELECT count(*) FROM submissions;
