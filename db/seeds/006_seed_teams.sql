-- Seed teams
INSERT INTO teams (id, public_id, workspace_id, name, icon, description, with_estimation, estimation_type, created_at, updated_at) VALUES
    ('11111111-1111-1111-1111-111111111111', 'ENG', '00000000-0000-0000-0000-000000000001', 'Engineering', '⚙️', 'Engineering team', true, 'fibonacci', '2024-02-01T00:00:00Z', '2024-02-01T00:00:00Z'),
    ('11111111-1111-1111-1111-111111111112', 'DESIGN', '00000000-0000-0000-0000-000000000001', 'Design', '🎨', 'Design team', false, NULL, '2024-02-01T00:00:00Z', '2024-02-01T00:00:00Z'),
    ('11111111-1111-1111-1111-111111111113', 'TEACH', '00000000-0000-0000-0000-000000000002', 'Teachers', '👩‍🏫', 'Teaching staff', true, 'tshirt', '2024-02-15T00:00:00Z', '2024-02-15T00:00:00Z')
ON CONFLICT (id) DO NOTHING;