-- =====================================================
-- 015_seed_issue_label_relations.sql
-- TYPE: Relationship / Junction Table
-- PURPOSE: Attach labels to issues for categorization
-- DEPENDENCIES:
--   - 010_seed_issue_labels.sql (label_id references)
--   - 011_seed_issues.sql (issue_id references)
-- CREATES: 5 label assignments
-- 
-- ASSIGNMENTS:
-- - ISSUE-04: Bug, Issue Tracking Test
-- - ISSUE-03: ideation (Design team label)
-- - ISSUE-02: Feature
-- - ISSUE-05: Bug (sub-issue inherits label)
-- 
-- NOTES:
-- - Issues can have multiple labels
-- - Team-specific labels only visible to team members
-- - Labels help with filtering and searching
-- =====================================================

-- Seed issue label relations
INSERT INTO issue_label_relations (issue_id, label_id, created_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440001'::uuid, '550e8400-e29b-41d4-a716-446655440300'::uuid, '2025-07-01T10:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440001'::uuid, '550e8400-e29b-41d4-a716-446655440303'::uuid, '2025-07-01T10:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440003'::uuid, '550e8400-e29b-41d4-a716-446655440302'::uuid, '2025-06-28T09:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440002'::uuid, '550e8400-e29b-41d4-a716-446655440301'::uuid, '2025-06-15T08:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440005'::uuid, '550e8400-e29b-41d4-a716-446655440300'::uuid, '2025-07-02T10:00:00Z')
ON CONFLICT DO NOTHING;