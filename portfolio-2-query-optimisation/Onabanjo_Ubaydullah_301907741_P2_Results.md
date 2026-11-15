# Query Performance Results

Data: one full 8-hour event with 10 teams, 960 flags and 200,000 submissions
(see Onabanjo_Ubaydullah_301907741_P2_GenerateData.sql). Plans were captured with EXPLAIN (ANALYZE, BUFFERS),
each run once to warm the cache and then saved (plans/Onabanjo_Ubaydullah_301907741_P2_PlanBefore.txt, plans/Onabanjo_Ubaydullah_301907741_P2_PlanAfter.txt).

## Summary
| Query | Before | After | Pages read | Execution time |
|---|---|---|---|---|
| Q2 captures per hour | Bitmap Heap Scan using one_capture_per_team_flag | Index Only Scan using idx_submissions_accepted_time | 940 -> 19 | 5.429 ms -> 2.526 ms |
| Q4 noisiest attackers in one tick | Parallel Seq Scan on submissions | Index Scan using idx_submissions_time | 1,706 -> 28 | 13.234 ms -> 1.418 ms |

## Q4: why it was slow and what changed
Q4 looks at one 5-minute tick, about 2,100 of the 200,000 submissions (around 1%).
With no index on submitted_at, PostgreSQL had to read the whole table and throw
away about 198,000 rows. It used two parallel processes to do this faster, but
still reads every page. The index on submitted_at lets it jump straight to the
12:00-12:05 range and read only those rows. Pages read fell about 60 times and
the query became about 9 times faster.

## Q2: already partly optimised, then fully
Before any new index, PostgreSQL already used the Portfolio 1 unique index
(one_capture_per_team_flag) to find the 4,004 accepted rows, so a rule added
for correctness also helped speed. It still had to visit 922 table pages to
read submitted_at. The new partial index holds only accepted rows, ordered by
submitted_at and carrying team_id, so the query is answered from the index
alone (Index Only Scan, Heap Fetches: 0).

## Trade-offs
- Every index makes inserts slightly slower. Submissions arrive constantly
  during the game, so only indexes that serve real queries were added.
- The partial index is small because it holds only the 2% of rows that are
  accepted.
- With a small table PostgreSQL may still choose a sequential scan; the
  difference shows at realistic volume.

## What the results say about the game
Every team stole almost every flag that was still unpatched, so the final
ranking was decided by how early each team patched its service. Team 01
patched at tick 5 and lost 36 flags; Team 10 patched at tick 86 and lost 765.
