-- Seed additional user roles (system roles already inserted in schema)
INSERT INTO user_roles (id, public_id, name, display_name, description, permissions, workspace_id, is_system, is_active, created_at, updated_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440604', 'ROLE-PROJECT-MANAGER', 'project_manager', 'Project Manager', 'Can manage projects and milestones in the workspace', '["projects.*", "milestones.*", "issues.create", "issues.update"]'::jsonb, '00000000-0000-0000-0000-000000000001', false, true, '2024-02-01T00:00:00Z', '2024-02-01T00:00:00Z')
ON CONFLICT (id) DO NOTHING;