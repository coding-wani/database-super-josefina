-- =====================================================
-- 008_seed_projects.sql
-- TYPE: Organization Structure / Core Entity
-- PURPOSE: Create projects that organize work across teams
-- DEPENDENCIES:
--   - 002_seed_workspaces.sql (projects belong to workspaces)
--   - 004_seed_users.sql (lead_id references users)
--   - 006_seed_teams.sql (optional team association)
-- CREATES: 2 projects with different statuses
-- 
-- PROJECTS:
-- - Website Redesign (PROJ-001): Engineering team, started
-- - Q1 Planning (PROJ-002): Workspace-level, completed
-- 
-- NOTES:
-- - next_milestone_number tracks milestone ID generation
-- - Projects can be workspace-level (team_id = NULL)
-- - Status: planned, started, paused, completed, canceled
-- =====================================================

-- Seed projects
INSERT INTO projects (id, public_id, workspace_id, team_id, name, icon, description, status, priority, lead_id, start_date, target_date, next_milestone_number, created_at, updated_at) VALUES
    ('22222222-2222-2222-2222-222222222221', 'PROJ-001', '00000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'Website Redesign', '🌐', 'Complete redesign of the company website', 'started', 'high', 'user-1', '2025-01-01', '2025-06-30', 3, '2024-12-01T00:00:00Z', '2025-01-15T00:00:00Z'),
    ('22222222-2222-2222-2222-222222222222', 'PROJ-002', '00000000-0000-0000-0000-000000000001', NULL, 'Q1 Planning', '📊', 'Quarterly planning for all teams', 'completed', 'urgent', 'user-3', '2024-12-15', '2025-01-15', 2, '2024-12-10T00:00:00Z', '2025-01-15T00:00:00Z')
ON CONFLICT (id) DO NOTHING;