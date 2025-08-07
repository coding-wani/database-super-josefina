CREATE TABLE IF NOT EXISTS user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    description TEXT,
    permissions JSONB DEFAULT '[]'::jsonb,  -- Array of permission strings
    workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,  -- NULL for global roles
    is_system BOOLEAN DEFAULT false,  -- System roles can't be deleted
    is_active BOOLEAN DEFAULT true,   -- Can be disabled without deletion
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Ensure role names are unique within a workspace (or globally if workspace_id is null)
    CONSTRAINT unique_role_name_per_workspace UNIQUE NULLS NOT DISTINCT (workspace_id, name)
);

-- Create indexes
CREATE INDEX idx_user_roles_workspace ON user_roles(workspace_id);
CREATE INDEX idx_user_roles_name ON user_roles(name);
CREATE INDEX idx_user_roles_is_active ON user_roles(is_active);

-- Create trigger for updated_at
CREATE TRIGGER update_user_roles_updated_at BEFORE UPDATE
    ON user_roles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default system roles (using predictable UUIDs for system roles)
-- Using UUID v5 with namespace OID and role name for deterministic IDs
INSERT INTO user_roles (id, public_id, name, display_name, description, permissions, is_system) VALUES
    ('550e8400-e29b-41d4-a716-446655440600'::uuid, 'ROLE-SUPER-ADMIN', 'super_admin', 'Super Administrator', 'Full system access across all workspaces', '["*"]'::jsonb, true),
    ('550e8400-e29b-41d4-a716-446655440601'::uuid, 'ROLE-BETA-TESTER', 'beta_tester', 'Beta Tester', 'Access to beta features and experimental functionality', '["features.beta.*"]'::jsonb, true),
    ('550e8400-e29b-41d4-a716-446655440602'::uuid, 'ROLE-SUPPORT', 'support_staff', 'Support Staff', 'Access to support tools and user assistance features', '["support.*", "users.view", "issues.view"]'::jsonb, true),
    ('550e8400-e29b-41d4-a716-446655440603'::uuid, 'ROLE-DEVELOPER', 'developer', 'Developer', 'Access to API and development tools', '["api.*", "dev_tools.*"]'::jsonb, true)
ON CONFLICT (public_id) DO NOTHING;