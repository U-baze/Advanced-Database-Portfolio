# Advanced Database Systems Portfolio (MIT 8103)

**Case study: AOT-CTF**, a live Attack-Defense Capture The Flag competition.
Ten teams each run a copy of OWASP Juice Shop, steal secret flags from each
other's copies and patch their own. Every 5 minutes (one tick) a new flag is
planted in each team's copy. A team scores +1 for each flag it steals and -1
for each of its own flags stolen. The database records every flag and every
submission, accepts or rejects submissions correctly when many arrive at
once, and serves the realtime game leaderboard.

Full description: [case-study.md](portfolio-1-database-design/case-study.md)

## Portfolios
| # | Topic | What it shows |
|---|---|---|
| 1 | [Database design and modelling](portfolio-1-database-design/) | ER diagram, four-table schema, keys and constraints, normalisation, eight rejected bad inserts |
| 2 | [Query processing and optimisation](portfolio-2-query-optimisation/) | 200,000 generated submissions, four queries, execution plans before and after indexes (Q4: 13.2 ms to 1.4 ms) |
| 3 | [Transactions and concurrency](portfolio-3-transactions-concurrency/) | Commit, rollback, savepoint; a double-capture race and its fix; READ COMMITTED vs REPEATABLE READ |
| 4 | [NoSQL and advanced data models](portfolio-4-nosql/) | Redis sorted-set leaderboard, live updates, rate limiting, rebuild from PostgreSQL |
| 5 | [Distributed and cloud databases](portfolio-5-distributed-cloud/) | Redis primary/replica with failure test; replication, consistency, sharding and cloud deployment |

## Technology
- PostgreSQL 17: source of truth (Portfolios 1-3)
- Redis 7: realtime game leaderboard and replica (Portfolios 4-5)
- Docker Compose on Ubuntu (WSL 2)

## How to run
1. Copy `.env.example` to `.env` and set the passwords.
2. Start the databases:
   ```bash
   docker compose up -d
   docker compose ps
   ```
3. Follow the "How to run" section in each portfolio's README, in order 1 to 5.

## Repository layout
```
docker-compose.yml               PostgreSQL, Redis, MongoDB
portfolio-1-database-design/     schema, sample data, constraint tests, ER diagram
portfolio-2-query-optimisation/  data generator, queries, plans, results
portfolio-3-transactions-concurrency/
portfolio-4-nosql/               Redis leaderboard
portfolio-5-distributed-cloud/   Redis replica setup and discussion
docs/screenshots/                all evidence screenshots
```

## Sources
- OWASP Juice Shop (MIT licence): challenge list used as reference data,
  see [reference/SOURCE.md](portfolio-1-database-design/reference/SOURCE.md)
- PostgreSQL 17 documentation, Redis documentation
