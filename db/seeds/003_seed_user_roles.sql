-- =====================================================
-- 003_seed_user_roles.sql
-- TYPE: Foundation / Core Entity
-- PURPOSE: Define custom workspace-specific roles
-- DEPENDENCIES: 
--   - Schema 001_create_user_roles.sql (creates table + system roles)
--   - 002_seed_workspaces.sql (workspace for role assignment)
-- CREATES: 1 workspace-specific role (project_manager)
-- 
-- NOTES:
-- - System roles (super_admin, beta_tester, etc.) already exist from schema
-- - This adds a custom role for the "Interesting Workspace"
-- - Permissions use dot notation (e.g., "projects.*")
-- =====================================================

-- Seed additional user roles (system roles already inserted in schema)
-- Using predictable UUID for consistency
INSERT INTO user_roles (id, public_id, name, display_name, description, permissions, workspace_id, is_system, is_active, created_at, updated_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440604'::uuid, 'ROLE-PROJECT-MANAGER', 'project_manager', 'Project Manager', 'Can manage projects and milestones in the workspace', '["projects.*", "milestones.*", "issues.create", "issues.update"]'::jsonb, '00000000-0000-0000-0000-000000000001', false, true, '2024-02-01T00:00:00Z', '2024-02-01T00:00:00Z')
ON CONFLICT (id) DO NOTHING;