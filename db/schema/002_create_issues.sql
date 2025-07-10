-- Note: Comments table must be created before this due to circular reference
-- You may need to add the foreign key constraint later

CREATE TABLE IF NOT EXISTS issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) UNIQUE NOT NULL,
    priority VARCHAR(20) NOT NULL DEFAULT 'no-priority',
    status VARCHAR(20) NOT NULL DEFAULT 'backlog',
    title VARCHAR(255) NOT NULL,
    description TEXT,
    creator_id VARCHAR(50) NOT NULL REFERENCES users(id),
    parent_issue_id UUID REFERENCES issues(id),
    parent_comment_id VARCHAR(50), -- FK will be added after comments table
    due_date TIMESTAMP,
    assignee_id VARCHAR(50) REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_priority CHECK (priority IN ('no-priority', 'urgent', 'high', 'medium', 'low')),
    CONSTRAINT valid_status CHECK (status IN ('backlog', 'todo', 'in-progress', 'done', 'canceled', 'duplicate'))
);

CREATE TRIGGER update_issues_updated_at BEFORE UPDATE
    ON issues FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();