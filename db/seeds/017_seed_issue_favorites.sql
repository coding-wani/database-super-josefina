-- =====================================================
-- 017_seed_issue_favorites.sql
-- TYPE: Relationship / Junction Table
-- PURPOSE: Track user's favorite/starred issues
-- DEPENDENCIES:
--   - 004_seed_users.sql (user_id references)
--   - 011_seed_issues.sql (issue_id references)
-- CREATES: 5 favorite records
-- 
-- FAVORITES:
-- - user-1: ISSUE-04, ISSUE-02
-- - user-2: ISSUE-04
-- - user-3: ISSUE-01
-- - user-4: ISSUE-03
-- 
-- NOTES:
-- - Favorites appear in user's quick access list
-- - Different from subscriptions (visual vs notifications)
-- - Personal organization feature
-- =====================================================

-- Seed issue favorites
INSERT INTO issue_favorites (user_id, issue_id, favorited_at) VALUES
    ('user-1', '550e8400-e29b-41d4-a716-446655440001'::uuid, '2025-07-01T10:30:00Z'),
    ('user-2', '550e8400-e29b-41d4-a716-446655440001'::uuid, '2025-07-02T15:00:00Z'),
    ('user-3', '550e8400-e29b-41d4-a716-446655440000'::uuid, '2025-06-05T09:00:00Z'),
    ('user-4', '550e8400-e29b-41d4-a716-446655440003'::uuid, '2025-07-09T16:00:00Z'),
    ('user-1', '550e8400-e29b-41d4-a716-446655440002'::uuid, '2025-06-20T11:00:00Z')
ON CONFLICT DO NOTHING;