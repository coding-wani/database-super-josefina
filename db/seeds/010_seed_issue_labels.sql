-- Seed issue labels
INSERT INTO issue_labels (id, workspace_id, team_id, name, color, description, created_at, updated_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440300', '00000000-0000-0000-0000-000000000001', NULL, 'Bug', '#ef4444', 'Something isn''t working', '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440301', '00000000-0000-0000-0000-000000000001', NULL, 'Feature', '#8b5cf6', 'New feature or request', '2024-01-02T00:00:00Z', '2024-01-02T00:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440302', '00000000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111112', 'ideation', '#22c55e', 'Design team ideation phase', '2024-01-03T00:00:00Z', '2024-01-03T00:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440303', '00000000-0000-0000-0000-000000000001', NULL, 'Linear Test', '#3b82f6', 'Testing Linear features', '2024-01-04T00:00:00Z', '2024-01-04T00:00:00Z')
ON CONFLICT (id) DO NOTHING;