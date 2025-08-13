-- =====================================================
-- 011_seed_issues.sql
-- TYPE: Core Content / Primary Entity
-- PURPOSE: Create issues demonstrating all states and relationships
-- DEPENDENCIES:
--   - 002_seed_workspaces.sql (workspace_id required)
--   - 004_seed_users.sql (creator_id, assignee_id)
--   - 006_seed_teams.sql (optional team_id)
--   - 008_seed_projects.sql (optional project_id)
--   - 009_seed_milestones.sql (optional milestone_id)
-- CREATES: 14 issues (12 published, 2 drafts)
-- 
-- ISSUE BREAKDOWN:
-- Part 1: Main published issues (ISSUE-01 to ISSUE-04)
-- Part 2: Sub-issues (ISSUE-05 to ISSUE-10)
-- Part 3: Draft issues (2 drafts with publicId="DRAFT")
-- 
-- NOTES:
-- - Draft issues share publicId="DRAFT" until published
-- - Engineering team issues have estimation (1-6)
-- - Design team issues have no estimation
-- - Sub-issues inherit team from parent
-- =====================================================

-- Seed issues (part 1 - main published issues)
-- All issues with publicId like "ISSUE-XX" are published (that's how they got their publicId)
-- Issues with comments (ISSUE-04 and ISSUE-03) must be published
-- Note: Engineering team (11111111-1111-1111-1111-111111111111) has Fibonacci estimation enabled
INSERT INTO issues (id, public_id, workspace_id, team_id, project_id, milestone_id, priority, status, issue_state, title, description, creator_id, parent_issue_id, due_date, assignee_id, estimation, created_at, updated_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'ISSUE-04', '00000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222221', '550e8400-e29b-41d4-a716-446655440500', 'high', 'in-progress', 'published', 'Issue title 4', E'## Description\n\nThis is a **markdown** description with:\n- Bullet points\n- *Italic text*\n- [Links](https://example.com)\n\n### Code example\n```javascript\nconst example = ''code'';\n```', 'user-1', NULL, '2025-07-15T10:00:00Z', 'user-1', 5, '2025-07-01T10:00:00Z', '2025-07-10T14:30:00Z'),
    ('550e8400-e29b-41d4-a716-446655440003', 'ISSUE-03', '00000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111112', NULL, NULL, 'medium', 'todo', 'published', 'Issue title 3', 'Simple task description', 'user-2', NULL, '2025-07-20T15:00:00Z', 'user-2', NULL, '2025-06-28T09:00:00Z', '2025-07-09T11:20:00Z'),
    ('550e8400-e29b-41d4-a716-446655440002', 'ISSUE-02', '00000000-0000-0000-0000-000000000001', NULL, '22222222-2222-2222-2222-222222222222', NULL, 'no-priority', 'backlog', 'published', 'Issue title 2', E'### Research needed\n\nInvestigate the following:\n1. Performance metrics\n2. User feedback\n3. Implementation options', 'user-3', NULL, '2025-07-25T17:00:00Z', NULL, NULL, '2025-06-15T08:00:00Z', '2025-06-15T08:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440000', 'ISSUE-01', '00000000-0000-0000-0000-000000000001', NULL, NULL, NULL, 'urgent', 'done', 'published', 'Issue title 1', '**Completed** issue with full documentation', 'user-3', NULL, '2025-07-10T12:00:00Z', 'user-3', NULL, '2025-06-01T07:00:00Z', '2025-07-08T16:45:00Z')
ON CONFLICT (id) DO NOTHING;

-- Seed issues (part 2 - published sub-issues)
-- Sub-issues inherit team from parent, so they also need estimation values
INSERT INTO issues (id, public_id, workspace_id, team_id, project_id, milestone_id, priority, status, issue_state, title, description, creator_id, parent_issue_id, due_date, assignee_id, estimation, created_at, updated_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440005', 'ISSUE-05', '00000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222221', '550e8400-e29b-41d4-a716-446655440500', 'no-priority', 'done', 'published', 'Issue title 5', 'Sub-issue description in **markdown**', 'user-1', '550e8400-e29b-41d4-a716-446655440001', NULL, NULL, 2, '2025-07-02T10:00:00Z', '2025-07-05T10:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440006', 'ISSUE-06', '00000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222221', '550e8400-e29b-41d4-a716-446655440500', 'no-priority', 'in-progress', 'published', 'Issue title 6', NULL, 'user-1', '550e8400-e29b-41d4-a716-446655440001', NULL, NULL, 3, '2025-07-02T10:00:00Z', '2025-07-08T10:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440007', 'ISSUE-07', '00000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222221', '550e8400-e29b-41d4-a716-446655440501', 'no-priority', 'todo', 'published', 'Issue title 7', NULL, 'user-1', '550e8400-e29b-41d4-a716-446655440001', NULL, NULL, 1, '2025-07-02T10:00:00Z', '2025-07-02T10:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440008', 'ISSUE-08', '00000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222221', '550e8400-e29b-41d4-a716-446655440501', 'no-priority', 'backlog', 'published', 'Issue title 8', NULL, 'user-1', '550e8400-e29b-41d4-a716-446655440001', NULL, NULL, 2, '2025-07-02T10:00:00Z', '2025-07-02T10:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440009', 'ISSUE-09', '00000000-0000-0000-0000-000000000001', NULL, '22222222-2222-2222-2222-222222222222', '550e8400-e29b-41d4-a716-446655440502', 'medium', 'todo', 'published', 'Issue title 9', NULL, 'user-3', '550e8400-e29b-41d4-a716-446655440002', NULL, NULL, NULL, '2025-06-20T10:00:00Z', '2025-06-20T10:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440010', 'ISSUE-10', '00000000-0000-0000-0000-000000000001', NULL, '22222222-2222-2222-2222-222222222222', '550e8400-e29b-41d4-a716-446655440502', 'low', 'backlog', 'published', 'Issue title 10', NULL, 'user-3', '550e8400-e29b-41d4-a716-446655440002', NULL, NULL, NULL, '2025-06-20T10:00:00Z', '2025-06-20T10:00:00Z')
ON CONFLICT (id) DO NOTHING;

-- Seed issues (part 3 - DRAFT issues)
-- Draft issues have "DRAFT" as publicId until they get published and receive a real ISSUE-XX ID
-- Engineering team draft gets estimation value, Design team draft does not
INSERT INTO issues (id, public_id, workspace_id, team_id, project_id, milestone_id, priority, status, issue_state, title, description, creator_id, parent_issue_id, due_date, assignee_id, estimation, created_at, updated_at) VALUES
   ('550e8400-e29b-41d4-a716-446655440013', 'DRAFT', '00000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', NULL, NULL, 'medium', 'triage', 'draft', 'Draft: Implement new authentication flow', E'Need to redesign the authentication flow to support SSO.\n\nRequirements:\n- Support SAML 2.0\n- Support OAuth 2.0\n- Maintain backward compatibility', 'user-1', NULL, NULL, NULL, 6, '2025-07-11T09:00:00Z', '2025-07-11T09:00:00Z'),
   ('550e8400-e29b-41d4-a716-446655440014', 'DRAFT', '00000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111112', '22222222-2222-2222-2222-222222222221', NULL, 'low', 'triage', 'draft', 'Draft: UI/UX improvements for dashboard', E'Collecting ideas for dashboard improvements:\n- Better data visualization\n- Improved navigation\n- Dark mode support', 'user-2', NULL, NULL, NULL, NULL, '2025-07-11T14:30:00Z', '2025-07-11T14:30:00Z')
ON CONFLICT (id) DO NOTHING;