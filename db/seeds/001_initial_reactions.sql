-- =====================================================
-- 001_initial_reactions.sql
-- TYPE: Foundation / Core Entity
-- PURPOSE: Define all available emoji reactions for comments
-- DEPENDENCIES: None (first file, no dependencies)
-- CREATES: 12 reaction types with predictable UUIDs
-- 
-- NOTES:
-- - Uses predictable UUIDs (550e8400-...) for consistent testing
-- - These reactions can be used on comments via comment_reactions
-- - ON CONFLICT ensures idempotency (safe to re-run)
-- =====================================================

-- Use predictable UUIDs for reactions so we can reference them in seed data
INSERT INTO reactions (id, emoji, name, created_at, updated_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440200'::uuid, '🥰', 'heart_eyes', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440201'::uuid, '😊', 'slightly_smiling_face', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440202'::uuid, '🤔', 'thinking_face', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440203'::uuid, '🤐', 'face_with_hand_over_mouth', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440204'::uuid, '👍', 'thumbs_up', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440205'::uuid, '❤️', 'heart', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440206'::uuid, '🎉', 'party_popper', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440207'::uuid, '🚀', 'rocket', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440208'::uuid, '👎', 'thumbs_down', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440209'::uuid, '😄', 'smile', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440210'::uuid, '😕', 'confused', NOW(), NOW()),
    ('550e8400-e29b-41d4-a716-446655440211'::uuid, '👀', 'eyes', NOW(), NOW())
ON CONFLICT (name) DO NOTHING;