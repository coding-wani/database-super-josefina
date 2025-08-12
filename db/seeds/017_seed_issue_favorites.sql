-- Seed issue favorites
INSERT INTO issue_favorites (user_id, issue_id, favorited_at) VALUES
    ('user-1', '550e8400-e29b-41d4-a716-446655440001'::uuid, '2025-07-01T10:30:00Z'),
    ('user-2', '550e8400-e29b-41d4-a716-446655440001'::uuid, '2025-07-02T15:00:00Z'),
    ('user-3', '550e8400-e29b-41d4-a716-446655440000'::uuid, '2025-06-05T09:00:00Z'),
    ('user-4', '550e8400-e29b-41d4-a716-446655440003'::uuid, '2025-07-09T16:00:00Z'),
    ('user-1', '550e8400-e29b-41d4-a716-446655440002'::uuid, '2025-06-20T11:00:00Z')
ON CONFLICT DO NOTHING;