# Portfolio 2: Query Processing and Optimisation

Uses the Portfolio 1 schema with a full simulated 8-hour AOT-CTF event:
10 teams, 960 flags and 200,000 flag submissions.

## Files
| File | Purpose |
|---|---|
| generate-data.sql | Builds the event: flags for 96 ticks and 200,000 submissions, including each team's patch time |
| queries.sql | Four queries the competition needs |
| query-results.txt | Output of all four queries |
| explain.sql | EXPLAIN (ANALYZE, BUFFERS) for Q2 and Q4 |
| indexes.sql | The two indexes added |
| plans/before.txt, plans/after.txt | Execution plans before and after the indexes |
| results.md | Performance analysis |

## The four queries
1. **Leaderboard**: +1 per flag captured, -1 per flag lost, ranked with RANK().
2. **Captures per hour**: per team, with a running total (window function).
3. **Most-attacked teams**: flags lost and how many teams attacked each one.
4. **Noisiest attackers in one tick**: attempts, invalid flags and duplicates in a 5-minute window.

## How to run
```bash
docker exec -i aotctf-pg psql -U aotctf -d aotctf < portfolio-1-database-design/schema.sql
docker exec -i aotctf-pg psql -U aotctf -d aotctf < portfolio-1-database-design/sample-data.sql
docker exec -i aotctf-pg psql -U aotctf -d aotctf < portfolio-2-query-optimisation/generate-data.sql
docker exec -i aotctf-pg psql -U aotctf -d aotctf < portfolio-2-query-optimisation/queries.sql
docker exec -i aotctf-pg psql -U aotctf -d aotctf < portfolio-2-query-optimisation/explain.sql
docker exec -i aotctf-pg psql -U aotctf -d aotctf < portfolio-2-query-optimisation/indexes.sql
docker exec -i aotctf-pg psql -U aotctf -d aotctf < portfolio-2-query-optimisation/explain.sql
```
Data is random, so exact counts and timings vary slightly between runs.

## Evidence
Data volume by result:

![Data volume](../docs/screenshots/p2-data-volume.png)

Scoreboard:

![leaderboard](../docs/screenshots/p2-scoreboard.png)

Most-attacked teams and noisiest attackers:

![Queries](../docs/screenshots/p2-queries.png)

Q4 before the index (sequential scan of the whole table):

![Q4 before](../docs/screenshots/p2-q4-before.png)

Q4 after the index (index scan of one tick only):

![Q4 after](../docs/screenshots/p2-q4-after.png)

## Result in one line
Q4 went from 13.234 ms to 1.418 ms and from 1,706 pages read to 28; Q2 became
an index-only scan. Details are in [results.md](results.md).
