-- Seed workspaces
INSERT INTO workspaces (id, public_id, name, icon, description, created_at, updated_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'IW', 'Interesting Workspace', '🎯', 'Main workspace for our interesting projects', '2024-01-01T00:00:00Z', '2024-01-01T00:00:00Z'),
    ('00000000-0000-0000-0000-000000000002', 'SM', 'School Manager', '🎓', 'Educational management workspace', '2024-01-15T00:00:00Z', '2024-01-15T00:00:00Z')
ON CONFLICT (id) DO NOTHING;