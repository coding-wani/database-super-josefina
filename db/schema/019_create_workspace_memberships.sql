-- =====================================================
-- 019_create_workspace_memberships.sql
-- TYPE: Membership Table - User-Workspace Association
-- PURPOSE: Define which users belong to which workspaces
-- DEPENDENCIES:
--   - 002_create_workspaces.sql (workspace_id)
--   - 003_create_users.sql (user_id, invited_by)
-- 
-- DESCRIPTION:
-- Core multi-tenancy table.
-- Controls workspace access and roles.
-- Foundation for Row-Level Security.
-- 
-- KEY CONCEPTS:
-- - User can be in multiple workspaces
-- - Different role per workspace
-- - invited_by tracks invitation chain
-- - Basis for RLS policies
-- 
-- WORKSPACE ROLES:
-- - owner: Full control, billing, delete workspace
-- - admin: Manage users, settings, integrations
-- - member: Normal access, create/edit content
-- - guest: Read-only, limited access
-- 
-- CREATES:
-- - Table: workspace_memberships
-- - Indexes: user and workspace lookups
-- - Constraints: role validation, unique membership
-- =====================================================

CREATE TABLE IF NOT EXISTS workspace_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL DEFAULT 'member',
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    invited_by VARCHAR(50) REFERENCES users(id),
    CONSTRAINT valid_workspace_role CHECK (role IN ('owner', 'admin', 'member', 'guest')),
    CONSTRAINT unique_user_workspace UNIQUE (user_id, workspace_id)
);

CREATE INDEX idx_workspace_memberships_user ON workspace_memberships(user_id);
CREATE INDEX idx_workspace_memberships_workspace ON workspace_memberships(workspace_id);