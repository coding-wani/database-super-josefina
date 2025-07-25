CREATE TABLE IF NOT EXISTS teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) NOT NULL,
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    icon VARCHAR(50),
    description TEXT,
    -- New estimation fields
    with_estimation BOOLEAN NOT NULL DEFAULT false,
    estimation_type VARCHAR(20) DEFAULT 'linear' CHECK (estimation_type IN ('exponential', 'fibonacci', 'linear', 'tshirt', 'bouldering')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- Ensure team public_ids are unique within a workspace
    CONSTRAINT unique_team_public_id_per_workspace UNIQUE (workspace_id, public_id),
    -- Ensure estimation_type is only set when with_estimation is true
    CONSTRAINT estimation_type_requires_with_estimation CHECK (
        (with_estimation = false AND estimation_type IS NULL) OR
        (with_estimation = true AND estimation_type IS NOT NULL)
    )
);

CREATE INDEX idx_teams_workspace ON teams(workspace_id);
CREATE TRIGGER update_teams_updated_at BEFORE UPDATE
    ON teams FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();