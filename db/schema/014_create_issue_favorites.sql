CREATE TABLE IF NOT EXISTS issue_favorites (
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    favorited_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, issue_id)
);