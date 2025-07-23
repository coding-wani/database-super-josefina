-- db/schema/024_create_user_role_assignment_events.sql
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