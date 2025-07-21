-- Workspace and membership queries

-- Get workspace by ID
-- Usage: Replace $1 with workspace ID
SELECT id, public_id, name, icon, description, created_at, updated_at
FROM workspaces 
WHERE id = $1;

-- Get workspace by public ID (for URLs like /workspace/ABC)
-- Usage: Replace $1 with public ID (like "ABC")
SELECT id, public_id, name, icon, description, created_at, updated_at
FROM workspaces 
WHERE public_id = $1;

-- Get all workspaces for a user
-- Usage: Replace $1 with user ID
SELECT w.id, w.public_id, w.name, w.icon, w.description, w.created_at, w.updated_at,
       wm.role, wm.joined_at
FROM workspaces w
JOIN workspace_memberships wm ON w.id = wm.workspace_id
WHERE wm.user_id = $1
ORDER BY w.name;

-- Create new workspace
-- Usage: Replace $1-$4 with actual values
INSERT INTO workspaces (public_id, name, icon, description)
VALUES ($1, $2, $3, $4)
RETURNING id, public_id, name, icon, description, created_at, updated_at;

-- Add user to workspace
-- Usage: Replace $1-$4 with user_id, workspace_id, role, invited_by_user_id
INSERT INTO workspace_memberships (user_id, workspace_id, role, invited_by)
VALUES ($1, $2, $3, $4)
RETURNING id, user_id, workspace_id, role, joined_at, invited_by;

-- Update workspace membership role
-- Usage: Replace $1 with new role, $2 with user_id, $3 with workspace_id
UPDATE workspace_memberships 
SET role = $1
WHERE user_id = $2 AND workspace_id = $3;

-- Remove user from workspace
-- Usage: Replace $1 with user_id, $2 with workspace_id
DELETE FROM workspace_memberships 
WHERE user_id = $1 AND workspace_id = $2;

-- Get all teams in a workspace
-- Usage: Replace $1 with workspace ID
SELECT id, public_id, workspace_id, name, icon, description, created_at, updated_at
FROM teams 
WHERE workspace_id = $1
ORDER BY name;

-- Get team by ID
-- Usage: Replace $1 with team ID
SELECT id, public_id, workspace_id, name, icon, description, created_at, updated_at
FROM teams 
WHERE id = $1;

-- Create new team
-- Usage: Replace $1-$5 with public_id, workspace_id, name, icon, description
INSERT INTO teams (public_id, workspace_id, name, icon, description)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, public_id, workspace_id, name, icon, description, created_at, updated_at;

-- Add user to team
-- Usage: Replace $1-$3 with user_id, team_id, role
INSERT INTO team_memberships (user_id, team_id, role)
VALUES ($1, $2, $3)
RETURNING id, user_id, team_id, role, joined_at;

-- Get all members of a team
-- Usage: Replace $1 with team ID
SELECT u.id, u.username, u.email, u.avatar, u.first_name, u.last_name, u.is_online,
       tm.role as team_role, tm.joined_at
FROM users u
JOIN team_memberships tm ON u.id = tm.user_id
WHERE tm.team_id = $1
ORDER BY u.username;