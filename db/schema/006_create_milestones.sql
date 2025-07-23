CREATE TABLE IF NOT EXISTS milestones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Ensure milestone public_ids are unique within a project
    CONSTRAINT unique_milestone_public_id_per_project UNIQUE (project_id, public_id)
);

-- Indexes for performance
CREATE INDEX idx_milestones_project ON milestones(project_id);
CREATE INDEX idx_milestones_created_at ON milestones(created_at DESC);

-- Trigger for automatic timestamp updates
CREATE TRIGGER update_milestones_updated_at BEFORE UPDATE
    ON milestones FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();