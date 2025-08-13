-- =====================================================
-- 019_seed_issue_related_issues.sql
-- TYPE: Relationship / Junction Table (Bidirectional)
-- PURPOSE: Link related issues together
-- DEPENDENCIES:
--   - 011_seed_issues.sql (both issue_id and related_issue_id)
-- CREATES: 3 bidirectional relationships (6 total records)
-- 
-- RELATIONSHIPS:
-- - ISSUE-04 <-> ISSUE-03
-- - ISSUE-02 <-> ISSUE-01
-- - ISSUE-09 <-> ISSUE-10 (sub-issues related)
-- 
-- NOTES:
-- - Trigger automatically creates reverse relation
-- - Only insert one direction, trigger handles other
-- - Useful for tracking duplicate/related work
-- - Cannot relate issue to itself (constraint)
-- =====================================================

-- Seed issue related issues
-- Note: The trigger will automatically create bidirectional relations
-- So we only insert one direction for each pair
INSERT INTO issue_related_issues (issue_id, related_issue_id, created_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440001'::uuid, '550e8400-e29b-41d4-a716-446655440003'::uuid, '2025-07-03T14:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440002'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '2025-06-20T11:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440009'::uuid, '550e8400-e29b-41d4-a716-446655440010'::uuid, '2025-06-21T10:00:00Z')
ON CONFLICT DO NOTHING;