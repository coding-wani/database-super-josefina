-- =====================================================
-- project-queries.sql
-- PURPOSE: SQL queries for project and milestone management
-- TABLES USED: projects, milestones, issues, issue_labels
-- 
-- QUERY CATEGORIES:
-- 1. Project READ Operations
-- 2. Project CREATE/UPDATE Operations
-- 3. Milestone Operations
-- 4. Milestone Statistics
-- 5. Label Management
-- 
-- PARAMETER NOTATION:
-- $1, $2, etc. are PostgreSQL prepared statement placeholders
-- Replace with actual values when executing
-- 
-- BUSINESS RULES:
-- - Projects can be workspace-wide or team-specific
-- - Milestones ALWAYS belong to a project
-- - Labels can be workspace-wide or team-specific
-- =====================================================

-- =====================================================
-- SECTION 1: PROJECT READ OPERATIONS
-- =====================================================

-- =====================================================
-- Query: Get project by ID
-- Purpose: Fetch complete project details using UUID
-- Use Case: Project detail page, API endpoints
-- Parameters:
--   $1: Project UUID (e.g., '22222222-2222-2222-2222-222222222221')
-- Returns: Single project record with all fields
-- Fields Include:
--   - next_milestone_number: For auto-generating milestone IDs
--   - lead_id: Project manager/owner
--   - status: planned, started, paused, completed, canceled
-- Performance: Uses primary key index (very fast)
-- =====================================================
SELECT id, public_id, workspace_id, team_id, name, icon, description, status, priority,
       lead_id, start_date, target_date, next_milestone_number, created_at, updated_at
FROM projects 
WHERE id = $1;

-- =====================================================
-- Query: Get project by public ID
-- Purpose: Fetch project using human-readable ID
-- Use Case: URL routing (/project/PROJ-001)
-- Parameters:
--   $1: Public ID (e.g., 'PROJ-001')
-- Returns: Single project record
-- Note: public_id unique per workspace
-- Common: Used in URLs and user-facing displays
-- =====================================================
SELECT id, public_id, workspace_id, team_id, name, icon, description, status, priority,
       lead_id, start_date, target_date, next_milestone_number, created_at, updated_at
FROM projects 
WHERE public_id = $1;

-- =====================================================
-- Query: Get all projects in workspace
-- Purpose: List all projects in a workspace
-- Use Case: Projects dashboard, workspace overview
-- Parameters:
--   $1: Workspace UUID
-- Returns: All projects (team and workspace-level)
-- Sort: Newest first (created_at DESC)
-- Filter Ideas:
--   - Add AND status != 'canceled' for active only
--   - Add AND team_id IS NULL for workspace-level only
-- =====================================================
SELECT id, public_id, workspace_id, team_id, name, icon, description, status, priority,
       lead_id, start_date, target_date, next_milestone_number, created_at, updated_at
FROM projects 
WHERE workspace_id = $1
ORDER BY created_at DESC;

-- =====================================================
-- Query: Get projects for a team
-- Purpose: List all projects belonging to a team
-- Use Case: Team dashboard, team planning
-- Parameters:
--   $1: Team UUID
-- Returns: Only team-specific projects
-- Sort: Newest first
-- Note: Excludes workspace-level projects
-- =====================================================
SELECT id, public_id, workspace_id, team_id, name, icon, description, status, priority,
       lead_id, start_date, target_date, next_milestone_number, created_at, updated_at
FROM projects 
WHERE team_id = $1
ORDER BY created_at DESC;

-- =====================================================
-- Query: Get projects led by user
-- Purpose: Show projects where user is lead
-- Use Case: "My Projects" view, project manager dashboard
-- Parameters:
--   $1: User ID (VARCHAR like 'user-1')
-- Returns: All projects where user is lead
-- Sort: Newest first
-- Common Filter: AND status = 'started' for active only
-- =====================================================
SELECT id, public_id, workspace_id, team_id, name, icon, description, status, priority,
       lead_id, start_date, target_date, next_milestone_number, created_at, updated_at
FROM projects 
WHERE lead_id = $1
ORDER BY created_at DESC;

-- =====================================================
-- SECTION 2: PROJECT CREATE/UPDATE OPERATIONS
-- =====================================================

-- =====================================================
-- Query: Create new project
-- Purpose: Insert a new project
-- Use Case: Project creation form
-- Parameters:
--   $1: public_id - Human-readable ID (e.g., 'PROJ-001')
--   $2: workspace_id - Required, UUID
--   $3: team_id - Optional, NULL for workspace-level
--   $4: name - Project name, VARCHAR(255)
--   $5: icon - Optional emoji or image URL
--   $6: description - Optional, Markdown text
--   $7: status - 'planned', 'started', etc.
--   $8: priority - 'no-priority', 'low', 'medium', 'high', 'urgent'
--   $9: lead_id - Optional, user ID of project lead
--   $10: start_date - Optional, TIMESTAMPTZ
--   $11: target_date - Optional, TIMESTAMPTZ
-- Returns: Complete created project
-- Auto-fields:
--   - id: Generated UUID
--   - next_milestone_number: Starts at 1
--   - created_at, updated_at: Timestamps
-- =====================================================
INSERT INTO projects (public_id, workspace_id, team_id, name, icon, description, status, priority, lead_id, start_date, target_date)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
RETURNING id, public_id, workspace_id, team_id, name, icon, description, status, priority, lead_id, start_date, target_date, next_milestone_number, created_at, updated_at;

-- =====================================================
-- Query: Update project
-- Purpose: Modify existing project details
-- Use Case: Project settings, status updates
-- Parameters:
--   $1: name - New project name
--   $2: description - New description
--   $3: status - New status
--   $4: priority - New priority
--   $5: lead_id - New lead or NULL
--   $6: start_date - New start date
--   $7: target_date - New target date
--   $8: id - Project UUID to update
-- Auto-updates: updated_at timestamp
-- Note: Cannot change workspace_id or team_id
-- =====================================================
UPDATE projects 
SET name = $1, description = $2, status = $3, priority = $4, lead_id = $5, start_date = $6, target_date = $7, updated_at = NOW()
WHERE id = $8;

-- =====================================================
-- SECTION 3: MILESTONE OPERATIONS
-- =====================================================

-- =====================================================
-- Query: Get milestones for project
-- Purpose: List all milestones in a project
-- Use Case: Project timeline, milestone selector
-- Parameters:
--   $1: Project UUID
-- Returns: All milestones for the project
-- Sort: Chronological (created_at ASC)
-- Note: Join with milestone_stats view for progress
-- =====================================================
SELECT id, public_id, project_id, title, description, icon, created_at, updated_at
FROM milestones 
WHERE project_id = $1
ORDER BY created_at ASC;

-- =====================================================
-- Query: Get milestone by ID
-- Purpose: Fetch single milestone details
-- Use Case: Milestone detail page
-- Parameters:
--   $1: Milestone UUID
-- Returns: Single milestone record
-- Related: Often followed by issue count query
-- =====================================================
SELECT id, public_id, project_id, title, description, icon, created_at, updated_at
FROM milestones 
WHERE id = $1;

-- =====================================================
-- Query: Create new milestone
-- Purpose: Add milestone to project
-- Use Case: Sprint planning, release planning
-- Parameters:
--   $1: public_id - Like 'MILE-01', 'MILE-02'
--   $2: project_id - Required, parent project UUID
--   $3: title - Milestone name
--   $4: description - Optional details
--   $5: icon - Optional emoji
-- Returns: Created milestone
-- Note: public_id should use project's next_milestone_number
-- Side Effect: Increment project.next_milestone_number
-- =====================================================
INSERT INTO milestones (public_id, project_id, title, description, icon)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, public_id, project_id, title, description, icon, created_at, updated_at;

-- =====================================================
-- Query: Update milestone
-- Purpose: Modify milestone details
-- Use Case: Edit milestone modal
-- Parameters:
--   $1: title - New title
--   $2: description - New description
--   $3: icon - New icon
--   $4: id - Milestone UUID to update
-- Cannot Change: project_id (milestone can't move)
-- =====================================================
UPDATE milestones 
SET title = $1, description = $2, icon = $3, updated_at = NOW()
WHERE id = $4;

-- =====================================================
-- SECTION 4: MILESTONE STATISTICS
-- =====================================================

-- =====================================================
-- Query: Get milestone progress
-- Purpose: Count issues by status for milestone
-- Use Case: Progress bars, burndown charts
-- Parameters:
--   $1: Milestone UUID
-- Returns: Issue counts for each status
-- Statuses Counted:
--   - triage: New, unprocessed
--   - backlog: Accepted, not started
--   - todo: Ready to start
--   - planning: Being designed
--   - in-progress: Active work
--   - in-review: Awaiting review
--   - done: Completed
--   - commit: Merged/deployed
--   - canceled: Won't do
--   - decline: Rejected
--   - duplicate: Duplicate of another
-- Progress Calculation: (done + commit) / total
-- Alternative: Use milestone_stats view instead
-- =====================================================
SELECT 
    COUNT(*) as total_issues,
    COUNT(CASE WHEN status = 'triage' THEN 1 END) as triage_issues,
    COUNT(CASE WHEN status = 'backlog' THEN 1 END) as backlog_issues,
    COUNT(CASE WHEN status = 'todo' THEN 1 END) as todo_issues,
    COUNT(CASE WHEN status = 'planning' THEN 1 END) as planning_issues,
    COUNT(CASE WHEN status = 'in-progress' THEN 1 END) as in_progress_issues,
    COUNT(CASE WHEN status = 'in-review' THEN 1 END) as in_review_issues,
    COUNT(CASE WHEN status = 'done' THEN 1 END) as done_issues,
    COUNT(CASE WHEN status = 'commit' THEN 1 END) as commit_issues,
    COUNT(CASE WHEN status = 'canceled' THEN 1 END) as canceled_issues,
    COUNT(CASE WHEN status = 'decline' THEN 1 END) as decline_issues,
    COUNT(CASE WHEN status = 'duplicate' THEN 1 END) as duplicate_issues
FROM issues 
WHERE milestone_id = $1;

-- =====================================================
-- SECTION 5: LABEL MANAGEMENT
-- =====================================================

-- =====================================================
-- Query: Get all labels in workspace
-- Purpose: List available labels for issue tagging
-- Use Case: Label picker, label management page
-- Parameters:
--   $1: Workspace UUID
-- Returns: All labels (workspace and team-specific)
-- Sort: Alphabetical by name
-- Includes:
--   - Workspace-wide labels (team_id = NULL)
--   - Team-specific labels (team_id != NULL)
-- Note: User sees team labels only if team member
-- =====================================================
SELECT id, workspace_id, team_id, name, color, description
FROM issue_labels 
WHERE workspace_id = $1
ORDER BY name;

-- =====================================================
-- Query: Create new label
-- Purpose: Add new label to workspace/team
-- Use Case: Label creation form
-- Parameters:
--   $1: workspace_id - Required, UUID
--   $2: team_id - Optional, NULL for workspace-wide
--   $3: name - Label name, must be unique in workspace
--   $4: color - Hex color (#RRGGBB format)
--   $5: description - Optional explanation
-- Returns: Created label
-- Validation: Color must match regex '^#[0-9A-Fa-f]{6}$'
-- Constraint: Name unique per workspace
-- =====================================================
INSERT INTO issue_labels (workspace_id, team_id, name, color, description)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, workspace_id, team_id, name, color, description;