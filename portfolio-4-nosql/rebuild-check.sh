#!/usr/bin/env bash
# Compares Redis with PostgreSQL, rebuilds Redis from PostgreSQL, then compares again
PG="docker exec -i aotctf-pg psql -U aotctf -d aotctf -At"
RD="docker exec -i aotctf-redis redis-cli"

echo "--- PostgreSQL (source of truth): Team 05 and Team 06"
$PG < portfolio-4-nosql/load-leaderboard.sql | grep -E '"Team 0(5|6)"'

echo "--- Redis before rebuild"
echo "Team 05: $($RD ZSCORE aotctf:leaderboard 'Team 05')"
echo "Team 06: $($RD ZSCORE aotctf:leaderboard 'Team 06')"

echo "--- Rebuilding Redis from PostgreSQL"
$RD DEL aotctf:leaderboard > /dev/null
$PG < portfolio-4-nosql/load-leaderboard.sql | $RD > /dev/null

echo "--- Redis after rebuild"
echo "Team 05: $($RD ZSCORE aotctf:leaderboard 'Team 05')"
echo "Team 06: $($RD ZSCORE aotctf:leaderboard 'Team 06')"
