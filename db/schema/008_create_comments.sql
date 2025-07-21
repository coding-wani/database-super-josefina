CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- Changed to UUID
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    author_id VARCHAR(50) NOT NULL REFERENCES users(id),
    description TEXT NOT NULL,
    parent_issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES comments(id),  -- Changed to UUID
    thread_open BOOLEAN NOT NULL DEFAULT true,  -- Made NOT NULL with default
    comment_url VARCHAR(500) NOT NULL,  -- Made NOT NULL - required for sharing
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add foreign key constraint to issues table for parent_comment_id
ALTER TABLE issues 
    ADD CONSTRAINT fk_issues_parent_comment 
    FOREIGN KEY (parent_comment_id) 
    REFERENCES comments(id);

CREATE INDEX idx_comments_workspace ON comments(workspace_id);
CREATE INDEX idx_comments_team ON comments(team_id);

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE
    ON comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();