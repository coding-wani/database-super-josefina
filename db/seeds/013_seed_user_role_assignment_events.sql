-- =====================================================
-- 013_seed_user_role_assignment_events.sql
-- TYPE: Event/Audit Table (NOT a simple junction table)
-- PURPOSE: Create historical log of role assignments
-- DEPENDENCIES:
--   - 003_seed_user_roles.sql (role_id references)
--   - 004_seed_users.sql (user_id and assigned_by)
--   - 002_seed_workspaces.sql (workspace_id for scoped roles)
-- CREATES: 5 role assignment events
-- 
-- EVENTS:
-- - user-1: super_admin (system bootstrap)
-- - user-4: beta_tester (assigned by user-1)
-- - user-5: developer (assigned by user-1)
-- - user-2: project_manager in workspace (assigned by user-1)
-- - user-3: support_staff with expiration (temp role)
-- 
-- NOTES:
-- - This is an EVENT LOG, not current state
-- - Tracks who assigned roles and when
-- - Supports role expiration for temporary assignments
-- - Uses helper function to resolve role names to IDs
-- =====================================================

-- Seed user role assignment events
-- 
-- IMPORTANT: This is an EVENT LOG TABLE that records the complete history of role assignments.
-- Unlike simple junction tables, this tracks ALL assignment/removal/expiration events over time
-- for audit trails and activity feeds. Each row is a historical event, not just a current relationship.
-- This is why the table is in /entities/ rather than /relationships/.

-- Create a temporary function to safely get role IDs with error handling
CREATE OR REPLACE FUNCTION get_role_id_by_name(role_name VARCHAR, workspace_uuid UUID DEFAULT NULL) 
RETURNS UUID AS $$
DECLARE
    role_uuid UUID;
BEGIN
    IF workspace_uuid IS NULL THEN
        SELECT id INTO role_uuid FROM user_roles 
        WHERE name = role_name AND workspace_id IS NULL;
    ELSE
        SELECT id INTO role_uuid FROM user_roles 
        WHERE name = role_name AND workspace_id = workspace_uuid;
    END IF;
    
    IF role_uuid IS NULL THEN
        RAISE EXCEPTION 'Role % not found for workspace %', role_name, COALESCE(workspace_uuid::text, 'GLOBAL');
    END IF;
    
    RETURN role_uuid;
END;
$$ LANGUAGE plpgsql;

-- Insert role assignments using the helper function
INSERT INTO user_role_assignment_events (id, public_id, user_id, role_id, workspace_id, action, assigned_by, created_at, expires_at)
VALUES 
    -- Super admin assignment (system bootstrap, no assigned_by)
    (
        '550e8400-e29b-41d4-a716-446655440700'::uuid,
        'ROLE-EVT-001',
        'user-1',
        get_role_id_by_name('super_admin'),
        NULL,
        'assigned',
        NULL,
        '2024-01-01T00:00:00Z',
        NULL
    ),
    -- Beta tester assignment
    (
        '550e8400-e29b-41d4-a716-446655440701'::uuid,
        'ROLE-EVT-002',
        'user-4',
        get_role_id_by_name('beta_tester'),
        NULL,
        'assigned',
        'user-1',
        '2024-04-01T00:00:00Z',
        NULL
    ),
    -- Developer assignment
    (
        '550e8400-e29b-41d4-a716-446655440702'::uuid,
        'ROLE-EVT-003',
        'user-5',
        get_role_id_by_name('developer'),
        NULL,
        'assigned',
        'user-1',
        '2024-05-01T00:00:00Z',
        NULL
    ),
    -- Project manager assignment (workspace-specific)
    (
        '550e8400-e29b-41d4-a716-446655440703'::uuid,
        'ROLE-EVT-004',
        'user-2',
        get_role_id_by_name('project_manager', '00000000-0000-0000-0000-000000000001'::uuid),
        '00000000-0000-0000-0000-000000000001',
        'assigned',
        'user-1',
        '2024-02-01T00:00:00Z',
        NULL
    ),
    -- Support staff assignment (with expiration)
    (
        '550e8400-e29b-41d4-a716-446655440704'::uuid,
        'ROLE-EVT-005',
        'user-3',
        get_role_id_by_name('support_staff'),
        NULL,
        'assigned',
        'user-1',
        '2024-03-01T00:00:00Z',
        '2025-12-31T23:59:59Z'
    )
ON CONFLICT (id) DO NOTHING;

-- Clean up the temporary function
DROP FUNCTION IF EXISTS get_role_id_by_name(VARCHAR, UUID);