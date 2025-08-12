-- Seed issue related issues
-- Note: The trigger will automatically create bidirectional relations
-- So we only insert one direction for each pair
INSERT INTO issue_related_issues (issue_id, related_issue_id, created_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440001'::uuid, '550e8400-e29b-41d4-a716-446655440003'::uuid, '2025-07-03T14:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440002'::uuid, '550e8400-e29b-41d4-a716-446655440000'::uuid, '2025-06-20T11:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440009'::uuid, '550e8400-e29b-41d4-a716-446655440010'::uuid, '2025-06-21T10:00:00Z')
ON CONFLICT DO NOTHING;