-- =====================================================
-- 005_seed_workspace_memberships.sql
-- TYPE: Relationship / Junction Table
-- PURPOSE: Link users to workspaces with specific roles
-- DEPENDENCIES:
--   - 002_seed_workspaces.sql (workspaces must exist)
--   - 004_seed_users.sql (users must exist)
-- CREATES: 6 membership records
-- 
-- MEMBERSHIPS:
-- - IW Workspace: user-1 (owner), user-2 (admin), user-3 (member), 
--                 user-4 (member), user-5 (member)
-- - SM Workspace: user-3 (owner)
-- 
-- NOTES:
-- - invited_by tracks who invited each member (NULL for owners)
-- - Roles: owner > admin > member > guest
-- - User-3 is in both workspaces (different roles)
-- =====================================================

-- Seed workspace memberships
INSERT INTO workspace_memberships (id, user_id, workspace_id, role, joined_at, invited_by) VALUES
    ('33333333-3333-3333-3333-333333333331', 'user-1', '00000000-0000-0000-0000-000000000001', 'owner', '2024-01-01T00:00:00Z', NULL),
    ('33333333-3333-3333-3333-333333333332', 'user-2', '00000000-0000-0000-0000-000000000001', 'admin', '2024-01-05T00:00:00Z', 'user-1'),
    ('33333333-3333-3333-3333-333333333333', 'user-3', '00000000-0000-0000-0000-000000000001', 'member', '2024-01-10T00:00:00Z', 'user-1'),
    ('33333333-3333-3333-3333-333333333334', 'user-4', '00000000-0000-0000-0000-000000000001', 'member', '2024-02-01T00:00:00Z', 'user-2'),
    ('33333333-3333-3333-3333-333333333335', 'user-5', '00000000-0000-0000-0000-000000000001', 'member', '2024-03-01T00:00:00Z', 'user-2'),
    ('33333333-3333-3333-3333-333333333336', 'user-3', '00000000-0000-0000-0000-000000000002', 'owner', '2024-01-15T00:00:00Z', NULL)
ON CONFLICT (id) DO NOTHING;