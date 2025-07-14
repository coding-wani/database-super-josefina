-- Add workspace reference to users
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS current_workspace_id UUID REFERENCES workspaces(id);

-- Add multi-tenant columns to issues (make them nullable first)
ALTER TABLE issues 
ADD COLUMN IF NOT EXISTS workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS project_id UUID REFERENCES projects(id) ON DELETE SET NULL;

-- Add indexes for the new columns
CREATE INDEX IF NOT EXISTS idx_issues_workspace ON issues(workspace_id);
CREATE INDEX IF NOT EXISTS idx_issues_team ON issues(team_id);
CREATE INDEX IF NOT EXISTS idx_issues_project ON issues(project_id);

-- Add multi-tenant columns to comments
ALTER TABLE comments 
ADD COLUMN workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
ADD COLUMN team_id UUID REFERENCES teams(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_comments_workspace ON comments(workspace_id);
CREATE INDEX IF NOT EXISTS idx_comments_team ON comments(team_id);

-- Add multi-tenant columns to issue_labels
ALTER TABLE issue_labels 
ADD COLUMN IF NOT EXISTS workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS description TEXT;

CREATE INDEX IF NOT EXISTS idx_issue_labels_workspace ON issue_labels(workspace_id);
CREATE INDEX IF NOT EXISTS idx_issue_labels_team ON issue_labels(team_id);

-- Add workspace_id to links
ALTER TABLE links 
ADD COLUMN IF NOT EXISTS workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_links_workspace ON links(workspace_id);