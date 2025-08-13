-- =====================================================
-- user-queries.sql
-- PURPOSE: SQL queries for user management and profiles
-- TABLES USED: users, workspace_memberships, workspaces,
--              team_memberships, teams
-- 
-- QUERY CATEGORIES:
-- 1. User Profile Operations
-- 2. User Membership Queries
-- 3. User Updates
-- 4. Workspace User Management
-- 
-- SPECIAL NOTES:
-- - User ID is VARCHAR(50) for OAuth compatibility
-- - Roles array contains current role names
-- - current_workspace_id tracks last active workspace
-- =====================================================

-- =====================================================
-- SECTION 1: USER PROFILE OPERATIONS
-- =====================================================

-- =====================================================
-- Query: Get user by ID
-- Purpose: Fetch complete user profile
-- Use Case: Authentication, profile page, user popover
-- Parameters:
--   $1: User ID (VARCHAR like 'user-1' or 'google|123456')
-- Returns: Single user record with all fields
-- Fields Explained:
--   - id: OAuth-compatible identifier
--   - username: Unique display name
--   - email: Can be NULL for some OAuth providers
--   - avatar: URL to profile picture
--   - is_online: Real-time presence
--   - current_workspace_id: Last active workspace
--   - roles: Array of role names ['super_admin', 'beta_tester']
-- Performance: Primary key lookup (instant)
-- =====================================================
SELECT id, username, email, avatar, first_name, last_name, is_online, current_workspace_id, roles, created_at, updated_at
FROM users 
WHERE id = $1;

-- =====================================================
-- SECTION 2: USER MEMBERSHIP QUERIES
-- =====================================================

-- =====================================================
-- Query Set: Get user with workspace memberships
-- Purpose: Load user's workspaces for switcher
-- Use Case: App initialization, workspace switcher
-- Requires: Two separate queries for simplicity
-- =====================================================

-- =====================================================
-- Query 1: Get the user
-- Purpose: Base user data
-- Parameters:
--   $1: User ID
-- Note: Same as "Get user by ID" query above
-- =====================================================
SELECT id, username, email, avatar, first_name, last_name, is_online, current_workspace_id, roles, created_at, updated_at
FROM users 
WHERE id = $1;

-- =====================================================
-- Query 2: Get workspace memberships
-- Purpose: List all workspaces user belongs to
-- Parameters:
--   $1: User ID
-- Returns: Workspace details with membership info
-- Join: workspace_memberships → workspaces
-- Fields:
--   - Membership: id, role, joined_at, invited_by
--   - Workspace: public_id, name, icon, description
-- Use Case:
--   - Workspace switcher dropdown
--   - Multi-workspace navigation
--   - Permission checking
-- Sort: By workspace name
-- =====================================================
SELECT wm.id, wm.user_id, wm.workspace_id, wm.role, wm.joined_at, wm.invited_by,
       w.public_id, w.name as workspace_name, w.icon as workspace_icon, w.description as workspace_description
FROM workspace_memberships wm
JOIN workspaces w ON wm.workspace_id = w.id
WHERE wm.user_id = $1;

-- =====================================================
-- Query Set: Get user with team memberships
-- Purpose: Load user's teams for navigation
-- Use Case: Team sidebar, team switcher
-- Requires: Two separate queries
-- =====================================================

-- Query 1: Get the user (same as above, included for completeness)
-- SELECT id, username, email, avatar, first_name, last_name, is_online, current_workspace_id, roles, created_at, updated_at
-- FROM users 
-- WHERE id = $1;

-- =====================================================
-- Query 2: Get team memberships
-- Purpose: List all teams user belongs to
-- Parameters:
--   $1: User ID
-- Returns: Team details with membership info
-- Join: team_memberships → teams
-- Fields:
--   - Membership: id, role, joined_at
--   - Team: public_id, name, icon, description, workspace_id
-- Team Roles:
--   - lead: Can manage team settings
--   - member: Normal team access
--   - viewer: Read-only access
-- Note: Filter by workspace_id for current workspace teams
-- =====================================================
SELECT tm.id, tm.user_id, tm.team_id, tm.role, tm.joined_at,
       t.public_id, t.name as team_name, t.icon as team_icon, t.description as team_description,
       t.workspace_id
FROM team_memberships tm
JOIN teams t ON tm.team_id = t.id
WHERE tm.user_id = $1;

-- =====================================================
-- SECTION 3: USER UPDATE OPERATIONS
-- =====================================================

-- =====================================================
-- Query: Update user profile
-- Purpose: Modify user's personal information
-- Use Case: Profile settings page, onboarding
-- Parameters:
--   $1: username - New username (must be unique)
--   $2: email - New email (must be unique)
--   $3: avatar - New avatar URL
--   $4: first_name - New first name
--   $5: last_name - New last name
--   $6: id - User ID to update
-- Auto-updates: updated_at timestamp
-- Validation:
--   - Username must be unique (constraint)
--   - Email must be unique (constraint)
-- Cannot Change: id, roles (managed separately)
-- =====================================================
UPDATE users 
SET username = $1, email = $2, avatar = $3, first_name = $4, last_name = $5, updated_at = NOW()
WHERE id = $6;

-- =====================================================
-- Query: Update user online status
-- Purpose: Track user presence/activity
-- Use Case: Real-time presence indicators
-- Parameters:
--   $1: is_online - true/false
--   $2: id - User ID
-- Auto-updates: updated_at timestamp
-- Common Usage:
--   - Set true on login/activity
--   - Set false on logout/timeout
--   - Heartbeat every X minutes
-- Real-time: Can trigger presence broadcasts
-- =====================================================
UPDATE users 
SET is_online = $1, updated_at = NOW()
WHERE id = $2;

-- =====================================================
-- Query: Set user's current workspace
-- Purpose: Track which workspace user is viewing
-- Use Case: Workspace switching, login redirect
-- Parameters:
--   $1: workspace_id - UUID of workspace
--   $2: id - User ID
-- Auto-updates: updated_at timestamp
-- Effects:
--   - Changes data context for user
--   - Updates default workspace on login
--   - Affects workspace switcher UI
-- Validation: User must be member of workspace
-- =====================================================
UPDATE users 
SET current_workspace_id = $1, updated_at = NOW()
WHERE id = $2;

-- =====================================================
-- SECTION 4: WORKSPACE USER MANAGEMENT
-- =====================================================

-- =====================================================
-- Query: Get all users in workspace
-- Purpose: List workspace members with roles
-- Use Case: 
--   - Team management page
--   - User picker/assignee dropdown
--   - Workspace member directory
--   - @mention autocomplete
-- Parameters:
--   $1: Workspace UUID
-- Returns: Users with their workspace roles
-- Join: users → workspace_memberships
-- Fields:
--   - User: All profile fields
--   - workspace_role: owner/admin/member/guest
--   - joined_at: When user joined workspace
-- Sort: Alphabetical by username
-- Filter Ideas:
--   - Add WHERE is_online = true for online only
--   - Add WHERE wm.role = 'owner' for owners only
-- =====================================================
SELECT u.id, u.username, u.email, u.avatar, u.first_name, u.last_name, u.is_online,
       wm.role as workspace_role, wm.joined_at
FROM users u
JOIN workspace_memberships wm ON u.id = wm.user_id
WHERE wm.workspace_id = $1
ORDER BY u.username;

-- =====================================================
-- ADDITIONAL QUERY IDEAS (Not in original file)
-- =====================================================

-- =====================================================
-- Suggested: Search users by name/email
-- Purpose: User search functionality
-- Parameters:
--   $1: Search term (with % wildcards)
--   $2: Workspace UUID (for scoping)
-- Example Usage:
-- SELECT u.* FROM users u
-- JOIN workspace_memberships wm ON u.id = wm.user_id
-- WHERE wm.workspace_id = $2
--   AND (u.username ILIKE $1 
--        OR u.email ILIKE $1
--        OR u.first_name ILIKE $1
--        OR u.last_name ILIKE $1)
-- ORDER BY u.username;
-- =====================================================

-- =====================================================
-- Suggested: Get user's role history
-- Purpose: Audit trail of role changes
-- Parameters:
--   $1: User ID
-- Example Usage:
-- SELECT urae.*, ur.name, ur.display_name
-- FROM user_role_assignment_events urae
-- JOIN user_roles ur ON urae.role_id = ur.id
-- WHERE urae.user_id = $1
-- ORDER BY urae.created_at DESC;
-- =====================================================

-- =====================================================
-- Suggested: Get users without team
-- Purpose: Find unassigned workspace members
-- Parameters:
--   $1: Workspace UUID
-- Example Usage:
-- SELECT u.* FROM users u
-- JOIN workspace_memberships wm ON u.id = wm.user_id
-- LEFT JOIN team_memberships tm ON u.id = tm.user_id
-- WHERE wm.workspace_id = $1 AND tm.id IS NULL;
-- =====================================================