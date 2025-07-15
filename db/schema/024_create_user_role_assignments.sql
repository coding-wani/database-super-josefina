CREATE TABLE IF NOT EXISTS user_role_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID REFERENCES user_roles(id) ON DELETE CASCADE,
    workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,  -- For workspace-specific role assignments
    assigned_by VARCHAR(50) REFERENCES users(id),
    assigned_at TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP,  -- Optional expiration for temporary roles
    
    -- Prevent duplicate role assignments
    CONSTRAINT unique_user_role_assignment UNIQUE (user_id, role_id, workspace_id),
    -- Ensure workspace matches if assigning workspace-specific role
    CONSTRAINT workspace_role_consistency CHECK (
        (workspace_id IS NULL AND role_id IN (SELECT id FROM user_roles WHERE workspace_id IS NULL))
        OR
        (workspace_id IS NOT NULL AND role_id IN (SELECT id FROM user_roles WHERE workspace_id = user_role_assignments.workspace_id OR workspace_id IS NULL))
    )
);

-- Create indexes
CREATE INDEX idx_user_role_assignments_user ON user_role_assignments(user_id);
CREATE INDEX idx_user_role_assignments_role ON user_role_assignments(role_id);
CREATE INDEX idx_user_role_assignments_workspace ON user_role_assignments(workspace_id);
CREATE INDEX idx_user_role_assignments_expires ON user_role_assignments(expires_at) WHERE expires_at IS NOT NULL;