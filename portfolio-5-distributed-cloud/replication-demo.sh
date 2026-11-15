#!/usr/bin/env bash
# Redis primary/replica demonstration for the AOT-CTF leaderboard
P="docker exec aotctf-redis redis-cli"
R="docker exec aotctf-redis-replica redis-cli"

echo "=== 1. Roles"
$P INFO replication | grep -E "^role|connected_slaves"
$R INFO replication | grep -E "^role|master_link_status"

echo "=== 2. The same leaderboard on both servers (top 3)"
echo "Primary:"; $P ZREVRANGE aotctf:leaderboard 0 2 WITHSCORES
echo "Replica:"; $R ZREVRANGE aotctf:leaderboard 0 2 WITHSCORES

echo "=== 3. A capture written to the primary reaches the replica"
echo "Primary, Team 03 after +1:"; $P ZINCRBY aotctf:leaderboard 1 "Team 03"
sleep 1
echo "Replica, Team 03:"; $R ZSCORE aotctf:leaderboard "Team 03"

echo "=== 4. The replica refuses writes"
$R ZINCRBY aotctf:leaderboard 1 "Team 03"

echo "=== 5. Primary stopped: the replica still serves the scoreboard"
docker stop aotctf-redis > /dev/null
sleep 2
$R INFO replication | grep master_link_status
echo "Replica top 3 while the primary is down:"; $R ZREVRANGE aotctf:leaderboard 0 2 WITHSCORES

echo "=== 6. Primary restarted: the link recovers"
docker start aotctf-redis > /dev/null
for i in $(seq 1 20); do $R INFO replication | grep -q "master_link_status:up" && break; sleep 1; done
$R INFO replication | grep master_link_status

# Undo the demo capture so Redis matches PostgreSQL again
$P ZINCRBY aotctf:leaderboard -1 "Team 03" > /dev/null
