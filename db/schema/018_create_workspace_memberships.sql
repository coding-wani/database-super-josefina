CREATE TABLE IF NOT EXISTS workspace_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL DEFAULT 'member',
    joined_at TIMESTAMP NOT NULL DEFAULT NOW(),
    invited_by VARCHAR(50) REFERENCES users(id),
    CONSTRAINT valid_workspace_role CHECK (role IN ('owner', 'admin', 'member', 'guest')),
    CONSTRAINT unique_user_workspace UNIQUE (user_id, workspace_id)
);

CREATE INDEX idx_workspace_memberships_user ON workspace_memberships(user_id);
CREATE INDEX idx_workspace_memberships_workspace ON workspace_memberships(workspace_id);