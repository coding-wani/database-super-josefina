-- =====================================================
-- 012_seed_comments.sql
-- TYPE: Core Content / Communication
-- PURPOSE: Create comments and replies on issues
-- DEPENDENCIES:
--   - 004_seed_users.sql (author_id references)
--   - 006_seed_teams.sql (team_id inherited from issue)
--   - 011_seed_issues.sql (parent_issue_id required)
-- CREATES: 3 comments (1 root, 1 reply, 1 standalone)
-- 
-- COMMENTS:
-- - Comment on ISSUE-04 by user-4
-- - Reply to above comment by user-5
-- - Comment on ISSUE-03 by user-5 (thread closed)
-- 
-- NOTES:
-- - parent_comment_id creates threaded discussions
-- - comment_url provides deep linking
-- - thread_open controls if replies are allowed
-- - Comments can only be on published issues
-- =====================================================

-- Seed comments
-- Comments reference published issues (ISSUE-04 and ISSUE-03)
INSERT INTO comments (id, workspace_id, team_id, author_id, description, parent_issue_id, parent_comment_id, thread_open, comment_url, created_at, updated_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440100', '00000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'user-4', 'test comment', '550e8400-e29b-41d4-a716-446655440001', NULL, true, 'https://issuetracking.app/team/issue/ISSUE-04#comment-1', '2025-07-03T10:00:00Z', '2025-07-03T10:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440101', '00000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'user-5', 'this is a comment on another comment, we call it a reply', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440100', true, 'https://issuetracking.app/team/issue/ISSUE-04#comment-2', '2025-07-10T14:29:00Z', '2025-07-10T14:29:00Z'),
    ('550e8400-e29b-41d4-a716-446655440102', '00000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111112', 'user-5', E'test\n\nhihi', '550e8400-e29b-41d4-a716-446655440003', NULL, false, 'https://issuetracking.app/team/issue/ISSUE-03#comment-3', '2025-07-10T14:29:00Z', '2025-07-10T14:29:00Z')
ON CONFLICT (id) DO NOTHING;