-- =====================================================
-- 020_seed_links.sql
-- TYPE: Extension Data / Core Entity
-- PURPOSE: Attach external URLs to issues
-- DEPENDENCIES:
--   - 002_seed_workspaces.sql (workspace_id for RLS)
--   - 011_seed_issues.sql (issue_id references)
-- CREATES: 6 external links
-- 
-- LINKS:
-- - ISSUE-04: 3 news sites (research links)
-- - ISSUE-03: 1 link (The Atlantic)
-- - ISSUE-02: 2 links (Guardian, Washington Post)
-- 
-- NOTES:
-- - Links have title, URL, optional description
-- - Used for external documentation/references
-- - Workspace-scoped for RLS policies
-- - Can extract metadata from URLs
-- =====================================================

-- Seed links
INSERT INTO links (id, workspace_id, issue_id, title, url, description, created_at, updated_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440400'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, '550e8400-e29b-41d4-a716-446655440001'::uuid, 'British Newspaper Archive', 'https://www.britishnewspaperarchive.co.uk', 'The British Newspaper Archive is an online searchable database of historical newspapers from the British Library''s collection', '2025-07-02T11:00:00Z', '2025-07-02T11:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440401'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, '550e8400-e29b-41d4-a716-446655440001'::uuid, 'The Telegraph', 'https://www.telegraph.co.uk', 'The latest UK and world news, business, sport and lifestyle from The Telegraph', '2025-07-02T11:30:00Z', '2025-07-02T11:30:00Z'),
    ('550e8400-e29b-41d4-a716-446655440402'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, '550e8400-e29b-41d4-a716-446655440001'::uuid, 'The New York Times', 'https://www.nytimes.com', 'Live news, investigations, opinion, photos and video by the journalists of The New York Times', '2025-07-02T12:00:00Z', '2025-07-02T12:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440403'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, '550e8400-e29b-41d4-a716-446655440003'::uuid, 'The Atlantic', 'https://www.theatlantic.com', NULL, '2025-06-29T09:00:00Z', '2025-06-29T09:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440404'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, '550e8400-e29b-41d4-a716-446655440002'::uuid, 'The Guardian', 'https://www.theguardian.com', 'Latest news, sport, business, comment, analysis and reviews from the Guardian', '2025-06-16T10:00:00Z', '2025-06-16T10:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440405'::uuid, '00000000-0000-0000-0000-000000000001'::uuid, '550e8400-e29b-41d4-a716-446655440002'::uuid, 'The Washington Post', 'https://www.washingtonpost.com', 'Breaking news and analysis on politics, business, world national news, entertainment more', '2025-06-16T10:30:00Z', '2025-06-16T10:30:00Z')
ON CONFLICT (id) DO NOTHING;