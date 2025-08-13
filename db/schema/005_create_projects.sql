-- =====================================================
-- 005_create_projects.sql
-- TYPE: Organization Table - Work Container
-- PURPOSE: Group related issues and milestones
-- DEPENDENCIES:
--   - 002_create_workspaces.sql (projects in workspaces)
--   - 003_create_users.sql (lead_id references users)
--   - 004_create_teams.sql (optional team association)
--   - Function: update_updated_at_column() from 002
-- 
-- DESCRIPTION:
-- Projects organize work across teams or workspace-wide.
-- Can have milestones for tracking major deliverables.
-- Tracks status, priority, and timeline.
-- 
-- KEY CONCEPTS:
-- - Can be workspace-level (team_id = NULL) or team-specific
-- - next_milestone_number: Auto-increment for milestone IDs
-- - lead_id: Project manager/owner
-- - Status workflow: planned → started → completed
-- 
-- PROJECT STATUSES:
-- - planned: Not yet started
-- - started: Active development
-- - paused: Temporarily on hold
-- - completed: Successfully finished
-- - canceled: Abandoned
-- 
-- CREATES:
-- - Table: projects
-- - Indexes: workspace, team, lead lookups
-- - Trigger: auto-update updated_at timestamp
-- - Constraints: valid status and priority values
-- =====================================================

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
    start_date TIMESTAMPTZ,
    target_date TIMESTAMPTZ,
    -- Add milestone counter for generating public IDs
    next_milestone_number INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
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