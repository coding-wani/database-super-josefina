-- =====================================================
-- 009_create_issue_labels.sql
-- TYPE: Organization Table - Categorization System
-- PURPOSE: Flexible tagging system for issues
-- DEPENDENCIES:
--   - 002_create_workspaces.sql (workspace-scoped)
--   - 004_create_teams.sql (optional team-scoped)
--   - Function: update_updated_at_column() from 002
-- 
-- DESCRIPTION:
-- Labels categorize and filter issues.
-- Can be workspace-wide or team-specific.
-- Support color coding for visual organization.
-- 
-- KEY CONCEPTS:
-- - Workspace labels: Visible to all in workspace
-- - Team labels: Only visible to team members
-- - Color: Hex format (#RRGGBB) for UI display
-- - Many-to-many with issues via junction table
-- 
-- COMMON LABEL USES:
-- - Bug, Feature, Enhancement
-- - Priority levels
-- - Component/Module names
-- - Customer requests
-- 
-- CREATES:
-- - Table: issue_labels
-- - Indexes: workspace, team lookups
-- - Trigger: auto-update updated_at timestamp
-- - Constraint: unique names per workspace
-- =====================================================

CREATE TABLE IF NOT EXISTS issue_labels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- Changed to UUID
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    color VARCHAR(7) NOT NULL CHECK (color ~ '^#[0-9A-Fa-f]{6}$'),
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- Ensure label names are unique within a workspace
    CONSTRAINT unique_label_name_per_workspace UNIQUE (workspace_id, name)
);

CREATE INDEX idx_issue_labels_workspace ON issue_labels(workspace_id);
CREATE INDEX idx_issue_labels_team ON issue_labels(team_id);

CREATE TRIGGER update_issue_labels_updated_at BEFORE UPDATE
    ON issue_labels FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();