-- Add workspace reference to users
ALTER TABLE users 
ADD CONSTRAINT fk_users_current_workspace 
FOREIGN KEY (current_workspace_id) 
REFERENCES workspaces(id);

-- Add multi-tenant columns to issues
ALTER TABLE issues 
ADD COLUMN workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
ADD COLUMN team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
ADD COLUMN project_id UUID REFERENCES projects(id) ON DELETE SET NULL;

-- Add indexes for the new columns
CREATE INDEX idx_issues_workspace ON issues(workspace_id);
CREATE INDEX idx_issues_team ON issues(team_id);
CREATE INDEX idx_issues_project ON issues(project_id);

-- Add multi-tenant columns to comments
ALTER TABLE comments 
ADD COLUMN workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
ADD COLUMN team_id UUID REFERENCES teams(id) ON DELETE SET NULL;

CREATE INDEX idx_comments_workspace ON comments(workspace_id);
CREATE INDEX idx_comments_team ON comments(team_id);

-- Add multi-tenant columns to issue_labels
ALTER TABLE issue_labels 
ADD COLUMN workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
ADD COLUMN team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
ADD COLUMN description TEXT;

CREATE INDEX idx_issue_labels_workspace ON issue_labels(workspace_id);
CREATE INDEX idx_issue_labels_team ON issue_labels(team_id);

-- Add workspace_id to links
ALTER TABLE links 
ADD COLUMN workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE;

CREATE INDEX idx_links_workspace ON links(workspace_id);