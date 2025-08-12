-- Note: Comments table must be created before this due to parent_comment_id in comments table

CREATE TABLE IF NOT EXISTS issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Public ID is the user-facing identifier:
    -- - "DRAFT" for all draft issues (multiple drafts can share this value)
    -- - "ISSUE-XX" for published issues (unique sequential numbering)
    -- The actual unique identifier is always the UUID (id field)
    public_id VARCHAR(50) NOT NULL,
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    milestone_id UUID REFERENCES milestones(id) ON DELETE SET NULL,
    priority VARCHAR(20) NOT NULL DEFAULT 'no-priority',
    status VARCHAR(20) NOT NULL DEFAULT 'triage',
    issue_state VARCHAR(20) NOT NULL DEFAULT 'draft',
    title VARCHAR(255) NOT NULL,
    description TEXT,
    creator_id VARCHAR(50) NOT NULL REFERENCES users(id),
    parent_issue_id UUID REFERENCES issues(id),
    due_date TIMESTAMPTZ,
    assignee_id VARCHAR(50) REFERENCES users(id),
    -- Estimation is only used for teams with estimation enabled
    -- Uses Fibonacci scale (1,2,3,5,8,13) but we limit to 1-6 for simplicity
    estimation INTEGER CHECK (estimation >= 1 AND estimation <= 6),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_priority CHECK (priority IN ('no-priority', 'urgent', 'high', 'medium', 'low')),
    CONSTRAINT valid_status CHECK (status IN ('triage', 'backlog', 'todo', 'planning', 'in-progress', 'in-review', 'done', 'commit', 'canceled', 'decline', 'duplicate')),
    CONSTRAINT valid_issue_state CHECK (issue_state IN ('draft', 'published')),
    -- Ensure milestone can only be set if issue belongs to a project
    CONSTRAINT milestone_requires_project CHECK (
        milestone_id IS NULL OR project_id IS NOT NULL
    )
);

-- Note: We don't add a UNIQUE constraint on public_id because multiple drafts 
-- can have "DRAFT" as their public_id. The uniqueness is enforced at the 
-- application level when generating sequential ISSUE-XX numbers for published issues.

CREATE INDEX idx_issues_workspace ON issues(workspace_id);
CREATE INDEX idx_issues_team ON issues(team_id);
CREATE INDEX idx_issues_project ON issues(project_id);
CREATE INDEX idx_issues_milestone ON issues(milestone_id);
CREATE INDEX idx_issues_creator ON issues(creator_id);
CREATE INDEX idx_issues_assignee ON issues(assignee_id);
CREATE INDEX idx_issues_parent_issue ON issues(parent_issue_id);
CREATE INDEX idx_issues_status ON issues(status);
CREATE INDEX idx_issues_priority ON issues(priority);
CREATE INDEX idx_issues_issue_state ON issues(issue_state);
CREATE INDEX idx_issues_created_at ON issues(created_at DESC);
CREATE INDEX idx_issues_due_date ON issues(due_date) WHERE due_date IS NOT NULL;
CREATE INDEX idx_issues_estimation ON issues(estimation) WHERE estimation IS NOT NULL;

CREATE TRIGGER update_issues_updated_at BEFORE UPDATE
    ON issues FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();