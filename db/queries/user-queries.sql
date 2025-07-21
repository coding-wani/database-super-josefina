-- User-related queries for the application

-- Get user by ID (for authentication/profile)
-- Usage: Replace $1 with the user ID
SELECT id, username, email, avatar, first_name, last_name, is_online, current_workspace_id, roles, created_at, updated_at
FROM users 
WHERE id = $1;

-- Get user with their workspace memberships
-- Usage: Replace $1 with the user ID
-- This requires 2 separate queries - simpler than complex joins
-- Query 1: Get the user
SELECT id, username, email, avatar, first_name, last_name, is_online, current_workspace_id, roles, created_at, updated_at
FROM users 
WHERE id = $1;

-- Query 2: Get their workspace memberships
SELECT wm.id, wm.user_id, wm.workspace_id, wm.role, wm.joined_at, wm.invited_by,
       w.public_id, w.name as workspace_name, w.icon as workspace_icon, w.description as workspace_description
FROM workspace_memberships wm
JOIN workspaces w ON wm.workspace_id = w.id
WHERE wm.user_id = $1;

-- Get user with their team memberships
-- Usage: Replace $1 with the user ID
-- Query 1: Get the user (same as above)
-- Query 2: Get their team memberships
SELECT tm.id, tm.user_id, tm.team_id, tm.role, tm.joined_at,
       t.public_id, t.name as team_name, t.icon as team_icon, t.description as team_description,
       t.workspace_id
FROM team_memberships tm
JOIN teams t ON tm.team_id = t.id
WHERE tm.user_id = $1;

-- Update user profile
-- Usage: Replace $1-$6 with actual values
UPDATE users 
SET username = $1, email = $2, avatar = $3, first_name = $4, last_name = $5, updated_at = NOW()
WHERE id = $6;

-- Update user online status
-- Usage: Replace $1 with true/false, $2 with user ID
UPDATE users 
SET is_online = $1, updated_at = NOW()
WHERE id = $2;

-- Set user's current workspace
-- Usage: Replace $1 with workspace ID, $2 with user ID
UPDATE users 
SET current_workspace_id = $1, updated_at = NOW()
WHERE id = $2;

-- Get all users in a workspace (for team management)
-- Usage: Replace $1 with workspace ID
SELECT u.id, u.username, u.email, u.avatar, u.first_name, u.last_name, u.is_online,
       wm.role as workspace_role, wm.joined_at
FROM users u
JOIN workspace_memberships wm ON u.id = wm.user_id
WHERE wm.workspace_id = $1
ORDER BY u.username;