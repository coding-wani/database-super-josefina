-- =====================================================
-- 020_create_team_memberships.sql
-- TYPE: Membership Table - User-Team Association
-- PURPOSE: Define team composition and roles
-- DEPENDENCIES:
--   - 003_create_users.sql (user_id)
--   - 004_create_teams.sql (team_id)
-- 
-- DESCRIPTION:
-- Defines who belongs to which teams.
-- Team membership affects issue visibility.
-- Hierarchical roles for team management.
-- 
-- KEY CONCEPTS:
-- - User must be in workspace to join team
-- - Team-specific roles
-- - Controls access to team issues/labels
-- - Lead can manage team settings
-- 
-- TEAM ROLES:
-- - lead: Team manager, can edit team settings
-- - member: Normal team member, full access
-- - viewer: Read-only access to team content
-- 
-- CREATES:
-- - Table: team_memberships
-- - Indexes: user and team lookups
-- - Constraints: role validation, unique membership
-- =====================================================

CREATE TABLE IF NOT EXISTS team_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL DEFAULT 'member',
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT valid_team_role CHECK (role IN ('lead', 'member', 'viewer')),
    CONSTRAINT unique_user_team UNIQUE (user_id, team_id)
);

CREATE INDEX idx_team_memberships_user ON team_memberships(user_id);
CREATE INDEX idx_team_memberships_team ON team_memberships(team_id);