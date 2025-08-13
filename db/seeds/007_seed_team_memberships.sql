-- =====================================================
-- 007_seed_team_memberships.sql
-- TYPE: Relationship / Junction Table
-- PURPOSE: Assign users to teams with specific roles
-- DEPENDENCIES:
--   - 004_seed_users.sql (users must exist)
--   - 006_seed_teams.sql (teams must exist)
-- CREATES: 5 team membership records
-- 
-- ASSIGNMENTS:
-- - Engineering: user-1 (lead), user-4 (member), user-5 (member)
-- - Design: user-2 (lead)
-- - Teachers: user-3 (lead)
-- 
-- NOTES:
-- - Team roles: lead > member > viewer
-- - Only leads can manage team settings
-- - Members must also be in the workspace
-- =====================================================

-- Seed team memberships
INSERT INTO team_memberships (id, user_id, team_id, role, joined_at) VALUES
    ('44444444-4444-4444-4444-444444444441', 'user-1', '11111111-1111-1111-1111-111111111111', 'lead', '2024-02-01T00:00:00Z'),
    ('44444444-4444-4444-4444-444444444442', 'user-4', '11111111-1111-1111-1111-111111111111', 'member', '2024-02-05T00:00:00Z'),
    ('44444444-4444-4444-4444-444444444443', 'user-5', '11111111-1111-1111-1111-111111111111', 'member', '2024-03-01T00:00:00Z'),
    ('44444444-4444-4444-4444-444444444444', 'user-2', '11111111-1111-1111-1111-111111111112', 'lead', '2024-02-01T00:00:00Z'),
    ('44444444-4444-4444-4444-444444444445', 'user-3', '11111111-1111-1111-1111-111111111113', 'lead', '2024-02-15T00:00:00Z')
ON CONFLICT (id) DO NOTHING;