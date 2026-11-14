-- AOT-CTF schema (Portfolio 1), PostgreSQL 17
DROP TABLE IF EXISTS submissions, flags, players, teams;

CREATE TABLE teams (
  team_id   SERIAL PRIMARY KEY,
  team_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE players (
  player_id   SERIAL PRIMARY KEY,
  team_id     INT NOT NULL REFERENCES teams (team_id),
  player_name VARCHAR(80) NOT NULL,
  UNIQUE (player_id, team_id)          -- lets submissions check the player is on the team
);

CREATE TABLE flags (
  flag_id    SERIAL PRIMARY KEY,
  team_id    INT NOT NULL REFERENCES teams (team_id),
  tick_no    INT NOT NULL CHECK (tick_no BETWEEN 1 AND 96),
  flag_hash  CHAR(64) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  UNIQUE (team_id, tick_no),           -- one flag per team per tick
  CHECK (expires_at > created_at)
);

CREATE TABLE submissions (
  submission_id BIGSERIAL PRIMARY KEY,
  team_id       INT NOT NULL REFERENCES teams (team_id),
  player_id     INT NOT NULL,
  flag_id       INT REFERENCES flags (flag_id),
  submitted_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  result        VARCHAR(10) NOT NULL
                CHECK (result IN ('accepted', 'expired', 'own_flag', 'duplicate', 'invalid')),
  FOREIGN KEY (player_id, team_id) REFERENCES players (player_id, team_id),
  CHECK ((result = 'invalid') = (flag_id IS NULL))   -- only invalid submissions have no flag
);

-- A team can capture each flag only once
CREATE UNIQUE INDEX one_capture_per_team_flag
  ON submissions (team_id, flag_id)
  WHERE result = 'accepted';
