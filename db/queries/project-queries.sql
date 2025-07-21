-- Project and milestone queries

-- Get project by ID
-- Usage: Replace $1 with project ID
SELECT id, public_id, workspace_id, team_id, name, icon, description, status, priority,
       lead_id, start_date, target_date, next_milestone_number, created_at, updated_at
FROM projects 
WHERE id = $1;

-- Get project by public ID
-- Usage: Replace $1 with public ID
SELECT id, public_id, workspace_id, team_id, name, icon, description, status, priority,
       lead_id, start_date, target_date, next_milestone_number, created_at, updated_at
FROM projects 
WHERE public_id = $1;

-- Get all projects in a workspace
-- Usage: Replace $1 with workspace ID
SELECT id, public_id, workspace_id, team_id, name, icon, description, status, priority,
       lead_id, start_date, target_date, next_milestone_number, created_at, updated_at
FROM projects 
WHERE workspace_id = $1
ORDER BY created_at DESC;

-- Get projects for a team
-- Usage: Replace $1 with team ID
SELECT id, public_id, workspace_id, team_id, name, icon, description, status, priority,
       lead_id, start_date, target_date, next_milestone_number, created_at, updated_at
FROM projects 
WHERE team_id = $1
ORDER BY created_at DESC;

-- Get projects led by a user
-- Usage: Replace $1 with user ID
SELECT id, public_id, workspace_id, team_id, name, icon, description, status, priority,
       lead_id, start_date, target_date, next_milestone_number, created_at, updated_at
FROM projects 
WHERE lead_id = $1
ORDER BY created_at DESC;

-- Create new project
-- Usage: Replace $1-$9 with actual values
INSERT INTO projects (public_id, workspace_id, team_id, name, icon, description, status, priority, lead_id, start_date, target_date)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
RETURNING id, public_id, workspace_id, team_id, name, icon, description, status, priority, lead_id, start_date, target_date, next_milestone_number, created_at, updated_at;

-- Update project
-- Usage: Replace $1-$8 with new values and project ID
UPDATE projects 
SET name = $1, description = $2, status = $3, priority = $4, lead_id = $5, start_date = $6, target_date = $7, updated_at = NOW()
WHERE id = $8;

-- Get milestones for a project
-- Usage: Replace $1 with project ID
SELECT id, public_id, project_id, title, description, icon, created_at, updated_at
FROM milestones 
WHERE project_id = $1
ORDER BY created_at ASC;

-- Get milestone by ID
-- Usage: Replace $1 with milestone ID
SELECT id, public_id, project_id, title, description, icon, created_at, updated_at
FROM milestones 
WHERE id = $1;

-- Create new milestone
-- Usage: Replace $1-$5 with actual values
INSERT INTO milestones (public_id, project_id, title, description, icon)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, public_id, project_id, title, description, icon, created_at, updated_at;

-- Update milestone
-- Usage: Replace $1-$4 with new values and milestone ID
UPDATE milestones 
SET title = $1, description = $2, icon = $3, updated_at = NOW()
WHERE id = $4;

-- Get milestone progress (simple count)
-- Usage: Replace $1 with milestone ID
SELECT 
    COUNT(*) as total_issues,
    COUNT(CASE WHEN status = 'done' THEN 1 END) as completed_issues,
    COUNT(CASE WHEN status = 'in-progress' THEN 1 END) as in_progress_issues,
    COUNT(CASE WHEN status = 'todo' THEN 1 END) as todo_issues,
    COUNT(CASE WHEN status = 'backlog' THEN 1 END) as backlog_issues
FROM issues 
WHERE milestone_id = $1;

-- Get all labels in a workspace
-- Usage: Replace $1 with workspace ID
SELECT id, workspace_id, team_id, name, color, description
FROM issue_labels 
WHERE workspace_id = $1
ORDER BY name;

-- Create new label
-- Usage: Replace $1-$5 with actual values
INSERT INTO issue_labels (workspace_id, team_id, name, color, description)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, workspace_id, team_id, name, color, description;