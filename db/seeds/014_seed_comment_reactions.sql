-- =====================================================
-- 014_seed_comment_reactions.sql
-- TYPE: Relationship / Junction Table
-- PURPOSE: Assign emoji reactions to comments
-- DEPENDENCIES:
--   - 001_initial_reactions.sql (reaction_id references)
--   - 004_seed_users.sql (user_id references)
--   - 012_seed_comments.sql (comment_id references)
-- CREATES: 6 reaction assignments
-- 
-- REACTIONS:
-- - Comment 1: heart_eyes (user-1), thumbs_up (user-2)
-- - Comment 2: thinking (user-4), thumbs_up (user-5, user-1)
-- - Comment 3: heart (user-3)
-- 
-- NOTES:
-- - Multiple users can use same reaction on a comment
-- - Same user can't duplicate reaction (primary key constraint)
-- - Reactions aggregate in API responses
-- =====================================================

-- Seed comment reactions
INSERT INTO comment_reactions (user_id, comment_id, reaction_id, reacted_at) VALUES
    ('user-1', '550e8400-e29b-41d4-a716-446655440100'::uuid, '550e8400-e29b-41d4-a716-446655440200'::uuid, '2025-07-03T10:15:00Z'),
    ('user-2', '550e8400-e29b-41d4-a716-446655440100'::uuid, '550e8400-e29b-41d4-a716-446655440204'::uuid, '2025-07-03T11:00:00Z'),
    ('user-4', '550e8400-e29b-41d4-a716-446655440101'::uuid, '550e8400-e29b-41d4-a716-446655440202'::uuid, '2025-07-10T14:30:00Z'),
    ('user-5', '550e8400-e29b-41d4-a716-446655440101'::uuid, '550e8400-e29b-41d4-a716-446655440204'::uuid, '2025-07-10T14:31:00Z'),
    ('user-1', '550e8400-e29b-41d4-a716-446655440101'::uuid, '550e8400-e29b-41d4-a716-446655440204'::uuid, '2025-07-10T14:32:00Z'),
    ('user-3', '550e8400-e29b-41d4-a716-446655440102'::uuid, '550e8400-e29b-41d4-a716-446655440205'::uuid, '2025-07-10T15:00:00Z')
ON CONFLICT DO NOTHING;