-- =====================================================
-- workspace-queries.sql
-- PURPOSE: SQL queries for workspace and team management
-- TABLES USED: workspaces, workspace_memberships, teams,
--              team_memberships, users
-- 
-- QUERY CATEGORIES:
-- 1. Workspace READ Operations
-- 2. Workspace CREATE Operations
-- 3. Workspace Membership Management
-- 4. Team Operations
-- 5. Team Membership Management
-- 
-- MULTI-TENANCY:
-- - Workspaces are the root of data isolation
-- - RLS policies use workspace membership
-- - Teams exist within workspaces
-- =====================================================

-- =====================================================
-- SECTION 1: WORKSPACE READ OPERATIONS
-- =====================================================

-- =====================================================
-- Query: Get workspace by ID
-- Purpose: Fetch workspace details using UUID
-- Use Case: Loading workspace settings, API calls
-- Parameters:
--   $1: Workspace UUID (e.g., '00000000-0000-0000-0000-000000000001')
-- Returns: Single workspace record
-- Security: RLS ensures user has access
-- Performance: Primary key lookup (instant)
-- =====================================================
SELECT id, public_id, name, icon, description, created_at, updated_at
FROM workspaces 
WHERE id = $1;

-- =====================================================
-- Query: Get workspace by public ID
-- Purpose: Fetch workspace using human-readable ID
-- Use Case: URL routing (/workspace/IW), user navigation
-- Parameters:
--   $1: Public ID (e.g., 'IW', 'ACME')
-- Returns: Single workspace record
-- Common: Used in URLs and workspace switcher
-- Note: public_id must be globally unique
-- =====================================================
SELECT id, public_id, name, icon, description, created_at, updated_at
FROM workspaces 
WHERE public_id = $1;

-- =====================================================
-- Query: Get all workspaces for user
-- Purpose: List workspaces user is member of
-- Use Case: 
--   - Workspace switcher dropdown
--   - User dashboard
--   - Multi-workspace navigation
-- Parameters:
--   $1: User ID (VARCHAR like 'user-1')
-- Returns: Workspaces with membership details
-- Join: workspaces ← workspace_memberships
-- Fields:
--   - Workspace: All details
--   - role: User's role in workspace
--   - joined_at: When user joined
-- Sort: Alphabetical by name
-- Note: Forms basis of RLS access control
-- =====================================================
SELECT w.id, w.public_id, w.name, w.icon, w.description, w.created_at, w.updated_at,
       wm.role, wm.joined_at
FROM workspaces w
JOIN workspace_memberships wm ON w.id = wm.workspace_id
WHERE wm.user_id = $1
ORDER BY w.name;

-- =====================================================
-- SECTION 2: WORKSPACE CREATE OPERATIONS
-- =====================================================

-- =====================================================
-- Query: Create new workspace
-- Purpose: Initialize a new workspace
-- Use Case: Workspace creation flow
-- Parameters:
--   $1: public_id - Unique identifier (e.g., 'ACME')
--   $2: name - Display name (e.g., 'Acme Corporation')
--   $3: icon - Optional emoji or image URL
--   $4: description - Optional workspace description
-- Returns: Created workspace with auto-generated fields
-- Auto-generated:
--   - id: UUID
--   - created_at, updated_at: Timestamps
-- Side Effects:
--   - Creator should be added as owner
--   - Default team can be created
-- Business Rules:
--   - public_id must be globally unique
--   - Creator becomes workspace owner
-- =====================================================
INSERT INTO workspaces (public_id, name, icon, description)
VALUES ($1, $2, $3, $4)
RETURNING id, public_id, name, icon, description, created_at, updated_at;

-- =====================================================
-- SECTION 3: WORKSPACE MEMBERSHIP MANAGEMENT
-- =====================================================

-- =====================================================
-- Query: Add user to workspace
-- Purpose: Grant user access to workspace
-- Use Case: 
--   - Inviting new members
--   - Onboarding flow
--   - Workspace creation (add creator)
-- Parameters:
--   $1: user_id - User to add (VARCHAR)
--   $2: workspace_id - Target workspace (UUID)
--   $3: role - 'owner', 'admin', 'member', or 'guest'
--   $4: invited_by - User who invited (VARCHAR, can be NULL)
-- Returns: Created membership record
-- Roles Explained:
--   - owner: Full control, billing, can delete
--   - admin: Manage users and settings
--   - member: Normal access, create content
--   - guest: Limited read access
-- Constraint: User can only be in workspace once
-- =====================================================
INSERT INTO workspace_memberships (user_id, workspace_id, role, invited_by)
VALUES ($1, $2, $3, $4)
RETURNING id, user_id, workspace_id, role, joined_at, invited_by;

-- =====================================================
-- Query: Update workspace membership role
-- Purpose: Change user's role in workspace
-- Use Case: 
--   - Promoting/demoting users
--   - Permission management
-- Parameters:
--   $1: role - New role
--   $2: user_id - User to update
--   $3: workspace_id - Workspace context
-- Validation:
--   - Cannot remove last owner
--   - Only owners/admins can change roles
-- Note: Does not update joined_at
-- =====================================================
UPDATE workspace_memberships 
SET role = $1
WHERE user_id = $2 AND workspace_id = $3;

-- =====================================================
-- Query: Remove user from workspace
-- Purpose: Revoke workspace access
-- Use Case:
--   - Removing members
--   - User leaving workspace
--   - Offboarding
-- Parameters:
--   $1: user_id - User to remove
--   $2: workspace_id - Workspace to remove from
-- Cascading Effects:
--   - Removes from all teams in workspace
--   - Unassigns from issues
--   - Removes subscriptions
-- Validation:
--   - Cannot remove last owner
--   - Check for owned resources
-- =====================================================
DELETE FROM workspace_memberships 
WHERE user_id = $1 AND workspace_id = $2;

-- =====================================================
-- SECTION 4: TEAM OPERATIONS
-- =====================================================

-- =====================================================
-- Query: Get all teams in workspace
-- Purpose: List workspace teams
-- Use Case:
--   - Team selector
--   - Workspace overview
--   - Team management page
-- Parameters:
--   $1: Workspace UUID
-- Returns: All teams in workspace
-- Sort: Alphabetical by name
-- Note: User sees all teams but can only
--       access team issues if member
-- =====================================================
SELECT id, public_id, workspace_id, name, icon, description, created_at, updated_at
FROM teams 
WHERE workspace_id = $1
ORDER BY name;

-- =====================================================
-- Query: Get team by ID
-- Purpose: Fetch single team details
-- Use Case:
--   - Team settings page
--   - Team dashboard
--   - API endpoints
-- Parameters:
--   $1: Team UUID
-- Returns: Single team record
-- Related: Often followed by member list query
-- =====================================================
SELECT id, public_id, workspace_id, name, icon, description, created_at, updated_at
FROM teams 
WHERE id = $1;

-- =====================================================
-- Query: Create new team
-- Purpose: Add team to workspace
-- Use Case: Team creation flow
-- Parameters:
--   $1: public_id - Team identifier (e.g., 'ENG')
--   $2: workspace_id - Parent workspace UUID
--   $3: name - Team display name
--   $4: icon - Optional emoji
--   $5: description - Optional details
-- Returns: Created team
-- Auto-generated:
--   - id: UUID
--   - created_at, updated_at: Timestamps
-- Side Effects:
--   - Creator usually added as team lead
-- Note: public_id unique per workspace
-- Missing Fields (not in query):
--   - with_estimation: Default false
--   - estimation_type: NULL when not estimating
-- =====================================================
INSERT INTO teams (public_id, workspace_id, name, icon, description)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, public_id, workspace_id, name, icon, description, created_at, updated_at;

-- =====================================================
-- SECTION 5: TEAM MEMBERSHIP MANAGEMENT
-- =====================================================

-- =====================================================
-- Query: Add user to team
-- Purpose: Make user a team member
-- Use Case:
--   - Team invitations
--   - Team formation
--   - Project staffing
-- Parameters:
--   $1: user_id - User to add (VARCHAR)
--   $2: team_id - Target team (UUID)
--   $3: role - 'lead', 'member', or 'viewer'
-- Returns: Created membership
-- Roles Explained:
--   - lead: Manage team settings, edit all
--   - member: Full team access
--   - viewer: Read-only access
-- Prerequisite: User must be in workspace
-- Constraint: User can only have one role per team
-- =====================================================
INSERT INTO team_memberships (user_id, team_id, role)
VALUES ($1, $2, $3)
RETURNING id, user_id, team_id, role, joined_at;

-- =====================================================
-- Query: Get all members of team
-- Purpose: List team composition
-- Use Case:
--   - Team member list
--   - @mention suggestions
--   - Capacity planning
-- Parameters:
--   $1: Team UUID
-- Returns: Team members with details
-- Join: users ← team_memberships
-- Fields:
--   - User: Profile information
--   - team_role: Role in this team
--   - joined_at: When joined team
-- Sort: Alphabetical by username
-- Display Ideas:
--   - Group by role (leads first)
--   - Show online status indicators
--   - Include user avatars
-- =====================================================
SELECT u.id, u.username, u.email, u.avatar, u.first_name, u.last_name, u.is_online,
       tm.role as team_role, tm.joined_at
FROM users u
JOIN team_memberships tm ON u.id = tm.user_id
WHERE tm.team_id = $1
ORDER BY u.username;

-- =====================================================
-- ADDITIONAL QUERY IDEAS (Not in original file)
-- =====================================================

-- =====================================================
-- Suggested: Transfer workspace ownership
-- Purpose: Change workspace owner
-- Example:
-- UPDATE workspace_memberships
-- SET role = 'owner'
-- WHERE user_id = $1 AND workspace_id = $2;
-- -- Then demote old owner to admin
-- =====================================================

-- =====================================================
-- Suggested: Get teams user is NOT in
-- Purpose: Show available teams to join
-- Example:
-- SELECT t.* FROM teams t
-- WHERE t.workspace_id = $1
--   AND t.id NOT IN (
--     SELECT team_id FROM team_memberships
--     WHERE user_id = $2
--   );
-- =====================================================

-- =====================================================
-- Suggested: Count workspace members
-- Purpose: Show member count, check limits
-- Example:
-- SELECT COUNT(*) as member_count,
--        COUNT(CASE WHEN role = 'owner' THEN 1 END) as owner_count,
--        COUNT(CASE WHEN role = 'admin' THEN 1 END) as admin_count
-- FROM workspace_memberships
-- WHERE workspace_id = $1;
-- =====================================================