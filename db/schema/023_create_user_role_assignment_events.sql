-- =====================================================
-- 023_create_user_role_assignment_events.sql
-- TYPE: Event Log Table (NOT a junction table!)
-- PURPOSE: Audit trail for role assignments/removals
-- DEPENDENCIES:
--   - 001_create_user_roles.sql (role_id)
--   - 002_create_workspaces.sql (workspace_id)
--   - 003_create_users.sql (user_id, assigned_by)
-- 
-- DESCRIPTION:
-- Complete history of role changes over time.
-- NOT just current state - full audit trail.
-- Used for compliance and activity feeds.
-- 
-- KEY CONCEPTS:
-- - Event sourcing pattern
-- - Immutable log (no updates)
-- - Tracks WHO did WHAT WHEN
-- - Supports temporary roles (expires_at)
-- 
-- EVENT TYPES:
-- - assigned: Role granted to user
-- - removed: Role revoked from user
-- - expired: Temporary role expired
-- 
-- USE CASES:
-- - Audit trail for compliance
-- - Activity feed display
-- - Role history investigation
-- - Temporary contractor access
-- 
-- WHY NOT A JUNCTION TABLE:
-- - Junction tables show current state
-- - This shows complete history
-- - Multiple events for same user/role
-- - Tracks metadata (who, when, expiry)
-- 
-- CREATES:
-- - Table: user_role_assignment_events
-- - 6 indexes for various queries
-- - Constraint: workspace role consistency
-- =====================================================

-- =====================================================
-- USER ROLE ASSIGNMENT EVENTS - Event Log Table
-- =====================================================
-- IMPORTANT: This is an EVENT LOG TABLE that records the complete history 
-- of user role assignments, removals, and expirations.
-- 
-- Unlike simple junction tables (which would be in /relationships/), this table:
-- - Tracks ALL historical events, not just current state
-- - Maintains a complete audit trail of who assigned/removed roles and when
-- - Records expiration events for temporary role assignments
-- - Provides data for activity feeds and compliance reporting
-- 
-- Each row represents a discrete event that occurred at a specific time,
-- which is why this is modeled as an entity rather than a relationship.
-- =====================================================

CREATE TABLE IF NOT EXISTS user_role_assignment_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) UNIQUE NOT NULL, -- Added public ID like "ROLE-EVT-001"
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID REFERENCES user_roles(id) ON DELETE CASCADE,
    workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
    action VARCHAR(20) NOT NULL CHECK (action IN ('assigned', 'removed', 'expired')),
    assigned_by VARCHAR(50) REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    
    -- Note: No unique constraint - we want multiple events for the same user/role
    -- Ensure workspace matches if assigning workspace-specific role
    CONSTRAINT workspace_role_consistency CHECK (
        (workspace_id IS NULL AND role_id IN (SELECT id FROM user_roles WHERE workspace_id IS NULL))
        OR
        (workspace_id IS NOT NULL AND role_id IN (SELECT id FROM user_roles WHERE workspace_id = user_role_assignment_events.workspace_id OR workspace_id IS NULL))
    )
);

-- Create indexes
CREATE INDEX idx_user_role_events_user ON user_role_assignment_events(user_id);
CREATE INDEX idx_user_role_events_role ON user_role_assignment_events(role_id);
CREATE INDEX idx_user_role_events_workspace ON user_role_assignment_events(workspace_id);
CREATE INDEX idx_user_role_events_created ON user_role_assignment_events(created_at DESC);
CREATE INDEX idx_user_role_events_action ON user_role_assignment_events(action);
CREATE INDEX idx_user_role_events_public_id ON user_role_assignment_events(public_id); -- Index for public ID lookups