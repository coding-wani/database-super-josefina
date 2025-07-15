CREATE TABLE IF NOT EXISTS comment_issues (
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    is_sub_issue BOOLEAN DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (comment_id, issue_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_comment_issues_comment ON comment_issues(comment_id);
CREATE INDEX IF NOT EXISTS idx_comment_issues_issue ON comment_issues(issue_id);