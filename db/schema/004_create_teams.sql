CREATE TABLE IF NOT EXISTS teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) NOT NULL,
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    icon VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    -- Ensure team public_ids are unique within a workspace
    CONSTRAINT unique_team_public_id_per_workspace UNIQUE (workspace_id, public_id)
);

CREATE INDEX idx_teams_workspace ON teams(workspace_id);
CREATE TRIGGER update_teams_updated_at BEFORE UPDATE
    ON teams FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();