-- Seed user role assignment events
-- 
-- IMPORTANT: This is an EVENT LOG TABLE that records the complete history of role assignments.
-- Unlike simple junction tables, this tracks ALL assignment/removal/expiration events over time
-- for audit trails and activity feeds. Each row is a historical event, not just a current relationship.
-- This is why the table is in /entities/ rather than /relationships/.
--
-- Note: The role IDs must match those created in the user_roles table

-- Get the role IDs from the user_roles table
WITH role_ids AS (
    SELECT 
        id as role_id,
        name as role_name
    FROM user_roles
)
INSERT INTO user_role_assignment_events (id, public_id, user_id, role_id, workspace_id, action, assigned_by, created_at, expires_at)
SELECT 
    '550e8400-e29b-41d4-a716-446655440700'::uuid,
    'ROLE-EVT-001',
    'user-1',
    (SELECT role_id FROM role_ids WHERE role_name = 'super_admin'),
    NULL,
    'assigned',
    NULL,
    '2024-01-01T00:00:00Z',
    NULL
UNION ALL
SELECT 
    '550e8400-e29b-41d4-a716-446655440701'::uuid,
    'ROLE-EVT-002',
    'user-4',
    (SELECT role_id FROM role_ids WHERE role_name = 'beta_tester'),
    NULL,
    'assigned',
    'user-1',
    '2024-04-01T00:00:00Z',
    NULL
UNION ALL
SELECT 
    '550e8400-e29b-41d4-a716-446655440702'::uuid,
    'ROLE-EVT-003',
    'user-5',
    (SELECT role_id FROM role_ids WHERE role_name = 'developer'),
    NULL,
    'assigned',
    'user-1',
    '2024-05-01T00:00:00Z',
    NULL
UNION ALL
SELECT 
    '550e8400-e29b-41d4-a716-446655440703'::uuid,
    'ROLE-EVT-004',
    'user-2',
    '550e8400-e29b-41d4-a716-446655440604'::uuid, -- project_manager role
    '00000000-0000-0000-0000-000000000001',
    'assigned',
    'user-1',
    '2024-02-01T00:00:00Z',
    NULL
UNION ALL
SELECT 
    '550e8400-e29b-41d4-a716-446655440704'::uuid,
    'ROLE-EVT-005',
    'user-3',
    (SELECT role_id FROM role_ids WHERE role_name = 'support_staff'),
    NULL,
    'assigned',
    'user-1',
    '2024-03-01T00:00:00Z',
    '2025-12-31T23:59:59Z'
ON CONFLICT (id) DO NOTHING;