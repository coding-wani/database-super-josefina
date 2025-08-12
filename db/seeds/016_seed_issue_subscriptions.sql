-- Seed issue subscriptions
INSERT INTO issue_subscriptions (user_id, issue_id, subscribed_at) VALUES
    ('user-1', '550e8400-e29b-41d4-a716-446655440001'::uuid, '2025-07-01T10:00:00Z'),
    ('user-2', '550e8400-e29b-41d4-a716-446655440001'::uuid, '2025-07-02T14:00:00Z'),
    ('user-4', '550e8400-e29b-41d4-a716-446655440001'::uuid, '2025-07-03T09:00:00Z'),
    ('user-1', '550e8400-e29b-41d4-a716-446655440003'::uuid, '2025-06-28T09:00:00Z'),
    ('user-5', '550e8400-e29b-41d4-a716-446655440003'::uuid, '2025-07-09T11:00:00Z')
ON CONFLICT DO NOTHING;