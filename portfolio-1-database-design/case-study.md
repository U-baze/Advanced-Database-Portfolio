## 1. Case study Scenario
AOT-CTF is a live Capture The Flag competition in the Attack-Defense CTF style.
Ten teams take part, 4 players per team and each gets its own copy of the same vulnerable
web application (OWASP Juice Shop). Teams simultaneously launch offensive
attacks against their rivals' infrastructure to steal the secret flags, and
fix the weaknesses in their own infrastructure so their flags cannot be stolen.

The CTF event mirrors real-world security operations: attackers find a bug and
weaponize it at scale to exploit vulnerable organisations, while defenders
detect the attack and apply fixes and security controls under pressure,
keeping downtime to the barest minimum.

At the heart of the competition is the database, which keeps a record of every
flag planted and every flag submitted. Under the pressure of the game, it must
correctly accept or reject a high volume of submissions, even when many arrive
at the same moment, while keeping the live scoreboard accurate. This makes
AOT-CTF a practical case for database design, query performance, concurrency
control, NoSQL and distributed databases.

## 2. Nature of the System
The game runs in rounds called ticks, a tick lasts 5 minutes and the event has 96 ticks. At the start of every round, 
a new flag is placed in every team's copy of the vulnerable application server. 

A flag can be used for 15 minutes before it expires. Scoring is simple: a team gets +1 point for every flag it captures
and -1 point for every one of its own flags that another team steals.

## 3. Users of the Database

- CTF Players: submit the flags they steal and check their team's score.
- Gameserver: an automated program that creates a new flag for every team each round.
- CTF Organisers: set up teams and players, run the event and watch for cheating.
- CTF Leaderboard viewers: anyone following the live rankings.

## 4. Major Data Stored

- Teams: the name of each CTF team.
- Players: each player's name and the CTF team they belong to.
- Flags: the secret code, which team it belongs to, which tick it was created in and when it expires. Flags are stored 
  in hashed form, so a leaked database does not reveal them.
- Submissions: every flag a team sends in, who sent it, when, and whether it was accepted or rejected.

## 5. Key Operations

- Create flags: add a new flag for every team at the start of each tick.
- Check a submission: accept a flag only if it exists, has not expired, is not the team's own flag and has not already been
  used by that team.
- Record every attempt, accepted or not.
- Show the leaderboard: work out each team's points from accepted submissions and rank the teams.
- Spot suspicious activity: use the submission records to find teams sending far too many attempts, or many wrong flags.
