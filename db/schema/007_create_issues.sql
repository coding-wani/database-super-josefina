-- Note: Comments table must be created before this due to circular reference
-- You may need to add the foreign key constraint later

CREATE TABLE IF NOT EXISTS issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) UNIQUE NOT NULL,
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    milestone_id UUID REFERENCES milestones(id) ON DELETE SET NULL,
    priority VARCHAR(20) NOT NULL DEFAULT 'no-priority',
    status VARCHAR(20) NOT NULL DEFAULT 'backlog',
    title VARCHAR(255) NOT NULL,
    description TEXT,
    creator_id VARCHAR(50) NOT NULL REFERENCES users(id),
    parent_issue_id UUID REFERENCES issues(id),
    parent_comment_id UUID, -- Changed to UUID, FK will be added after comments table
    due_date TIMESTAMPTZ,
    assignee_id VARCHAR(50) REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_priority CHECK (priority IN ('no-priority', 'urgent', 'high', 'medium', 'low')),
    CONSTRAINT valid_status CHECK (status IN ('backlog', 'todo', 'in-progress', 'done', 'canceled', 'duplicate')),
    -- Ensure milestone can only be set if issue belongs to a project
    CONSTRAINT milestone_requires_project CHECK (
        milestone_id IS NULL OR project_id IS NOT NULL
    )
);

CREATE INDEX idx_issues_workspace ON issues(workspace_id);
CREATE INDEX idx_issues_team ON issues(team_id);
CREATE INDEX idx_issues_project ON issues(project_id);
CREATE INDEX idx_issues_milestone ON issues(milestone_id);

CREATE TRIGGER update_issues_updated_at BEFORE UPDATE
    ON issues FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();