CREATE TABLE IF NOT EXISTS comments (
    id VARCHAR(50) PRIMARY KEY,
    author_id VARCHAR(50) NOT NULL REFERENCES users(id),
    description TEXT NOT NULL,
    parent_issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    parent_comment_id VARCHAR(50) REFERENCES comments(id),
    thread_open BOOLEAN DEFAULT true,
    comment_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add foreign key constraint to issues table for parent_comment_id
ALTER TABLE issues 
    ADD CONSTRAINT fk_issues_parent_comment 
    FOREIGN KEY (parent_comment_id) 
    REFERENCES comments(id);

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE
    ON comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();