MIT 8103 Advanced Database Systems - Continuous Assessment (September 2026 cohort)
Student: Onabanjo Ubaydullah
Student ID: 301907741

Case study: AOT-CTF, a live Attack-Defense Capture The Flag competition.
Ten teams each run a copy of OWASP Juice Shop, steal flags from each other's
server and patch their own. A new flag is planted for every team each 5-minute
tick (96 ticks). A team scores +1 for each flag it steals and -1 for each flag
stolen from it.

GitHub repository (public):
https://github.com/U-baze/Advanced-Database-Portfolio

Contents of this submission:
- Onabanjo_Ubaydullah_301907741_FinalSummary.pdf  3-page summary of the five portfolios,
  reflection, AI-use declaration and references
- Onabanjo_Ubaydullah_301907741_README.txt        this file

Repository layout:
- portfolio-1-database-design           ER diagram, schema, sample data, constraint tests, normalisation
- portfolio-2-query-optimisation        data generator, queries, execution plans before/after indexes, results
- portfolio-3-transactions-concurrency  commit/rollback/savepoint, two-session race, isolation levels
- portfolio-4-nosql                     Redis sorted-set leaderboard, rate limit, rebuild from PostgreSQL
- portfolio-5-distributed-cloud         Redis primary/replica setup and distributed/cloud discussion
- docs/screenshots                      all evidence screenshots
Evidence files are named Onabanjo_Ubaydullah_301907741_P<portfolio>_<type>.
Each portfolio folder has an Onabanjo_Ubaydullah_301907741_P<n>_README.md explaining what was done, how to run it and the evidence.

How to run:
1. Copy .env.example to .env and set the passwords.
2. docker compose up -d   (PostgreSQL 17, Redis 7, MongoDB 7)
3. Follow the "How to run" section in each portfolio README, in order 1 to 5.

AI use: Claude (Anthropic) was used as a learning and drafting aid, as declared in the final summary.
