CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) NOT NULL,
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    icon VARCHAR(50),
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'planned',
    priority VARCHAR(20) NOT NULL DEFAULT 'medium',
    lead_id VARCHAR(50) REFERENCES users(id),
    start_date DATE,
    target_date DATE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_project_status CHECK (status IN ('planned', 'started', 'paused', 'completed', 'canceled')),
    CONSTRAINT valid_project_priority CHECK (priority IN ('no-priority', 'urgent', 'high', 'medium', 'low')),
    -- Ensure project public_ids are unique within a workspace
    CONSTRAINT unique_project_public_id_per_workspace UNIQUE (workspace_id, public_id)
);

CREATE INDEX idx_projects_workspace ON projects(workspace_id);
CREATE INDEX idx_projects_team ON projects(team_id);
CREATE INDEX idx_projects_lead ON projects(lead_id);
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE
    ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();