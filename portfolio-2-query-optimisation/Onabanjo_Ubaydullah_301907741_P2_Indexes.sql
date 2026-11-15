-- Index 1: any submission by time (helps Q4's one-tick window)
CREATE INDEX IF NOT EXISTS idx_submissions_time
  ON submissions (submitted_at);

-- Index 2: accepted captures only, ordered by time, carrying team_id
-- so Q2 can be answered from the index alone (index-only scan)
CREATE INDEX IF NOT EXISTS idx_submissions_accepted_time
  ON submissions (submitted_at) INCLUDE (team_id)
  WHERE result = 'accepted';

VACUUM ANALYZE submissions;
