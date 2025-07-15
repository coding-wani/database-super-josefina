CREATE TABLE IF NOT EXISTS issue_labels (
    id VARCHAR(50) PRIMARY KEY,
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    color VARCHAR(7) NOT NULL CHECK (color ~ '^#[0-9A-Fa-f]{6}$'),
    description TEXT,
    -- Ensure label names are unique within a workspace
    CONSTRAINT unique_label_name_per_workspace UNIQUE (workspace_id, name)
);

CREATE INDEX idx_issue_labels_workspace ON issue_labels(workspace_id);
CREATE INDEX idx_issue_labels_team ON issue_labels(team_id);