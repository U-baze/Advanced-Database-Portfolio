# Normalisation

## Starting point: one big table (unnormalised)
Imagine recording everything in a single submission log, where every row holds:
submission time, result, attacking team name, player name, flag value,
flag owner team name, tick number and flag expiry.

The potential problems with this are:
- Team names are repeated on thousands of rows, so renaming a team means
  updating thousands of rows (update anomaly).
- A flag cannot be recorded until someone submits it (insertion anomaly).
- Deleting a team's submissions could delete the only record of its flags
  (deletion anomaly).

## First Normal Form (1NF)
Every column stores a single value and every row has a unique identifier
(submission_id).

## Second Normal Form (2NF)
Details that describe a player, a flag or a team are moved into their own
tables (players, flags, teams), so nothing is dependent on only part of a key.

## Third Normal Form (3NF)
No column depends on another non-key column. For example, a flag's owner
team name is not stored on the flag; only team_id is, and the name lives
once in teams.

## A deliberate choice: the score is not stored
A team's score is calculated from accepted submissions (+1 per flag
captured, -1 per flag lost). Storing it as a column would duplicate data
that can go out of step.

## Comparison with OWASP Juice Shop
Juice Shop keeps a "solved" flag on each challenge row and stores tags as
a text value. This works for a single player but cannot show which of
ten teams captured what, so AOT-CTF records each capture as its own row
in submissions.
