-- =====================================================
-- 004_seed_users.sql
-- TYPE: Foundation / Core Entity
-- PURPOSE: Create user accounts with different roles
-- DEPENDENCIES:
--   - 002_seed_workspaces.sql (current_workspace_id references)
--   - System roles from schema (for roles array)
-- CREATES: 5 users with diverse roles and workspaces
-- 
-- USERS:
-- - user-1: John Doe (super_admin) - Workspace IW
-- - user-2: Jane Doe (project_manager) - Workspace IW
-- - user-3: Alex Smith (support_staff) - Workspace SM
-- - user-4: Gigi (beta_tester) - Workspace IW
-- - user-5: Julian Doe (developer) - Workspace IW
-- 
-- NOTES:
-- - IDs are VARCHAR(50) for OAuth compatibility (not UUID)
-- - Roles array contains role names for quick permission checks
-- - Avatar URLs use DiceBear API for consistent test avatars
-- =====================================================

-- Seed users with roles
INSERT INTO users (id, username, email, avatar, first_name, last_name, is_online, current_workspace_id, roles, created_at, updated_at) VALUES
    ('user-1', 'johndoe', 'john.doe@example.com', 'https://api.dicebear.com/7.x/avataaars/svg?seed=johndoe', 'John', 'Doe', true, '00000000-0000-0000-0000-000000000001', ARRAY['super_admin'], '2024-01-01T10:00:00Z', '2025-07-10T10:00:00Z'),
    ('user-2', 'janedoe', 'jane.doe@example.com', 'https://api.dicebear.com/7.x/avataaars/svg?seed=janedoe', 'Jane', 'Doe', false, '00000000-0000-0000-0000-000000000001', ARRAY['project_manager'], '2024-02-01T10:00:00Z', '2025-07-09T10:00:00Z'),
    ('user-3', 'alexsmith', 'alex.smith@example.com', 'https://api.dicebear.com/7.x/avataaars/svg?seed=alexsmith', 'Alex', 'Smith', true, '00000000-0000-0000-0000-000000000002', ARRAY['support_staff'], '2024-03-01T10:00:00Z', '2025-07-08T10:00:00Z'),
    ('user-4', 'gigi', 'gigi@example.com', 'https://api.dicebear.com/7.x/avataaars/svg?seed=gigi', 'Gigi', NULL, true, '00000000-0000-0000-0000-000000000001', ARRAY['beta_tester'], '2024-04-01T10:00:00Z', '2025-07-03T10:00:00Z'),
    ('user-5', 'juliandoe', 'julian.doe@example.com', 'https://api.dicebear.com/7.x/avataaars/svg?seed=juliandoe', 'Julian', 'Doe', false, '00000000-0000-0000-0000-000000000001', ARRAY['developer'], '2024-05-01T10:00:00Z', '2025-07-10T14:29:00Z')
ON CONFLICT (id) DO NOTHING;