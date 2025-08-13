-- =====================================================
-- issue-queries.sql
-- PURPOSE: SQL queries for issue management operations
-- TABLES USED: issues, issue_labels, issue_label_relations, 
--              issue_subscriptions, users
-- 
-- QUERY CATEGORIES:
-- 1. READ Operations (SELECT)
-- 2. CREATE Operations (INSERT)
-- 3. UPDATE Operations
-- 4. Label Management
-- 5. Subscription Management
-- 
-- PARAMETER NOTATION:
-- $1, $2, etc. are PostgreSQL prepared statement placeholders
-- Replace with actual values when executing
-- 
-- SECURITY NOTES:
-- - All queries respect RLS (Row-Level Security)
-- - User must have workspace access to see issues
-- - Team issues require team membership
-- =====================================================

-- =====================================================
-- SECTION 1: READ OPERATIONS
-- =====================================================

-- =====================================================
-- Query: Get issue by ID
-- Purpose: Fetch complete issue details using internal UUID
-- Use Case: Loading issue detail page, API endpoints
-- Parameters:
--   $1: Issue UUID (e.g., '550e8400-e29b-41d4-a716-446655440001')
-- Returns: Single issue record with all fields
-- Performance: Uses primary key index (very fast)
-- =====================================================
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE id = $1;

-- =====================================================
-- Query: Get issue by public ID
-- Purpose: Fetch issue using human-readable ID
-- Use Case: URL routing (/issue/ISSUE-123), user searches
-- Parameters:
--   $1: Public ID (e.g., 'ISSUE-123' or 'DRAFT')
-- Returns: Single issue or multiple if $1='DRAFT'
-- Note: 'DRAFT' can return multiple issues (not unique)
-- Performance: Consider adding index on public_id if slow
-- =====================================================
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE public_id = $1;

-- =====================================================
-- Query: Get all issues in workspace
-- Purpose: List all issues user can access in workspace
-- Use Case: Workspace dashboard, issue list views
-- Parameters:
--   $1: Workspace UUID
-- Returns: All issues (draft + published) in workspace
-- Sort: Newest first (created_at DESC)
-- RLS Note: Will filter based on team membership automatically
-- =====================================================
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE workspace_id = $1
ORDER BY created_at DESC;

-- =====================================================
-- Query: Get published issues only
-- Purpose: Show only visible/published issues
-- Use Case: Public boards, team views, reports
-- Parameters:
--   $1: Workspace UUID
-- Returns: Only published issues (excludes drafts)
-- Filter: issue_state = 'published'
-- Common Use: Default view for most users
-- =====================================================
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE workspace_id = $1 AND issue_state = 'published'
ORDER BY created_at DESC;

-- =====================================================
-- Query: Get issues assigned to user
-- Purpose: Show user's assigned work
-- Use Case: "My Issues" view, user dashboard
-- Parameters:
--   $1: User ID (VARCHAR like 'user-1')
-- Returns: All issues where user is assignee
-- Sort: Newest first
-- Tip: Add status filter for active work only
-- =====================================================
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE assignee_id = $1
ORDER BY created_at DESC;

-- =====================================================
-- Query: Get issues created by user
-- Purpose: Show issues user has created
-- Use Case: "Created by me" filter, user activity
-- Parameters:
--   $1: User ID (VARCHAR like 'user-1')
-- Returns: All issues where user is creator
-- Sort: Newest first
-- Note: Includes both draft and published
-- =====================================================
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE creator_id = $1
ORDER BY created_at DESC;

-- =====================================================
-- Query: Get issues in project
-- Purpose: List all issues belonging to a project
-- Use Case: Project overview, milestone planning
-- Parameters:
--   $1: Project UUID
-- Returns: All issues in project
-- Sort: Newest first
-- Related: Often combined with milestone filter
-- =====================================================
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE project_id = $1
ORDER BY created_at DESC;

-- =====================================================
-- Query: Get issues in milestone
-- Purpose: Show issues for specific milestone
-- Use Case: Sprint planning, release tracking
-- Parameters:
--   $1: Milestone UUID
-- Returns: All issues assigned to milestone
-- Sort: Newest first
-- Tip: Join with milestone_stats view for progress
-- =====================================================
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE milestone_id = $1
ORDER BY created_at DESC;

-- =====================================================
-- SECTION 2: CREATE OPERATIONS
-- =====================================================

-- =====================================================
-- Query: Create new issue
-- Purpose: Insert a new issue (usually as draft)
-- Use Case: Issue creation form submission
-- Parameters:
--   $1: public_id - 'DRAFT' initially, 'ISSUE-XX' when published
--   $2: workspace_id - Required, UUID
--   $3: team_id - Optional, NULL for workspace-level
--   $4: project_id - Optional, NULL if not in project
--   $5: milestone_id - Optional, NULL or requires project_id
--   $6: priority - 'no-priority', 'low', 'medium', 'high', 'urgent'
--   $7: status - 'triage', 'backlog', 'todo', etc.
--   $8: issue_state - 'draft' or 'published'
--   $9: title - Required, VARCHAR(255)
--   $10: description - Optional, Markdown text
--   $11: creator_id - Required, user ID
--   $12: assignee_id - Optional, user ID
-- Returns: Complete created issue with auto-generated fields
-- Note: id, created_at, updated_at are auto-generated
-- =====================================================
INSERT INTO issues (public_id, workspace_id, team_id, project_id, milestone_id, priority, status, issue_state, title, description, creator_id, assignee_id)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
RETURNING id, public_id, workspace_id, team_id, project_id, milestone_id, priority, status, issue_state, title, description, creator_id, assignee_id, created_at, updated_at;

-- =====================================================
-- SECTION 3: UPDATE OPERATIONS
-- =====================================================

-- =====================================================
-- Query: Update issue
-- Purpose: Modify existing issue fields
-- Use Case: Edit issue form, status changes
-- Parameters:
--   $1: title - New title
--   $2: description - New description
--   $3: priority - New priority
--   $4: status - New status
--   $5: issue_state - 'draft' or 'published'
--   $6: assignee_id - New assignee or NULL
--   $7: due_date - New due date or NULL
--   $8: id - Issue UUID to update
-- Auto-updates: updated_at timestamp
-- Note: Consider separate queries for specific updates
-- =====================================================
UPDATE issues 
SET title = $1, description = $2, priority = $3, status = $4, issue_state = $5, assignee_id = $6, due_date = $7, updated_at = NOW()
WHERE id = $8;

-- =====================================================
-- Query: Publish draft issue
-- Purpose: Change issue from draft to published state
-- Use Case: "Publish" button on draft issues
-- Parameters:
--   $1: Issue UUID
-- Validation: Only works if current state is 'draft'
-- Side Effects: 
--   - Makes issue visible to team
--   - Should trigger notifications
--   - App should assign sequential public_id
-- =====================================================
UPDATE issues 
SET issue_state = 'published', updated_at = NOW()
WHERE id = $1 AND issue_state = 'draft';

-- =====================================================
-- Query: Unpublish issue (revert to draft)
-- Purpose: Hide published issue, revert to draft
-- Use Case: Mistakenly published, needs major rework
-- Parameters:
--   $1: Issue UUID
-- Validation: Only works if current state is 'published'
-- Warning: Will hide from team views
-- Note: Rarely used in practice
-- =====================================================
UPDATE issues 
SET issue_state = 'draft', updated_at = NOW()
WHERE id = $1 AND issue_state = 'published';

-- =====================================================
-- SECTION 4: LABEL MANAGEMENT
-- =====================================================

-- =====================================================
-- Query: Get labels for an issue
-- Purpose: Fetch all labels attached to an issue
-- Use Case: Display labels on issue card/detail
-- Parameters:
--   $1: Issue UUID
-- Returns: Label details including color
-- Join: issue_labels ← issue_label_relations
-- Performance: Uses foreign key indexes
-- =====================================================
SELECT il.id, il.workspace_id, il.team_id, il.name, il.color, il.description
FROM issue_labels il
JOIN issue_label_relations ilr ON il.id = ilr.label_id
WHERE ilr.issue_id = $1;

-- =====================================================
-- Query: Add label to issue
-- Purpose: Attach a label to an issue
-- Use Case: Label picker, bulk labeling
-- Parameters:
--   $1: Issue UUID
--   $2: Label UUID
-- Constraint: Primary key prevents duplicates
-- Note: Silently fails if label already attached
-- =====================================================
INSERT INTO issue_label_relations (issue_id, label_id)
VALUES ($1, $2);

-- =====================================================
-- Query: Remove label from issue
-- Purpose: Detach a label from an issue
-- Use Case: Label removal, label editor
-- Parameters:
--   $1: Issue UUID
--   $2: Label UUID
-- Note: No error if label wasn't attached
-- =====================================================
DELETE FROM issue_label_relations 
WHERE issue_id = $1 AND label_id = $2;

-- =====================================================
-- SECTION 5: SUBSCRIPTION MANAGEMENT
-- =====================================================

-- =====================================================
-- Query: Get issue subscribers
-- Purpose: List users subscribed to an issue
-- Use Case: Notification list, subscriber count
-- Parameters:
--   $1: Issue UUID
-- Returns: User details for all subscribers
-- Join: users ← issue_subscriptions
-- Common: Show avatars of subscribers
-- =====================================================
SELECT u.id, u.username, u.email, u.avatar, u.first_name, u.last_name
FROM users u
JOIN issue_subscriptions isub ON u.id = isub.user_id
WHERE isub.issue_id = $1;

-- =====================================================
-- Query: Subscribe user to issue
-- Purpose: Add user to issue notifications
-- Use Case: "Watch" button, auto-subscribe
-- Parameters:
--   $1: User ID (VARCHAR)
--   $2: Issue UUID
-- Auto-subscribe: Creator, assignee, commenters
-- Constraint: Primary key prevents duplicates
-- =====================================================
INSERT INTO issue_subscriptions (user_id, issue_id)
VALUES ($1, $2);

-- =====================================================
-- Query: Unsubscribe user from issue
-- Purpose: Remove user from notifications
-- Use Case: "Unwatch" button, mute notifications
-- Parameters:
--   $1: User ID (VARCHAR)
--   $2: Issue UUID
-- Note: No error if not subscribed
-- =====================================================
DELETE FROM issue_subscriptions 
WHERE user_id = $1 AND issue_id = $2;