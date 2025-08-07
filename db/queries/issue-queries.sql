-- Issue management queries

-- Get issue by ID with basic info
-- Usage: Replace $1 with issue ID
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id, parent_comment_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE id = $1;

-- Get issue by public ID (for URLs like /issue/ISSUE-123)
-- Usage: Replace $1 with public ID
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id, parent_comment_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE public_id = $1;

-- Get all issues in a workspace
-- Usage: Replace $1 with workspace ID
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id, parent_comment_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE workspace_id = $1
ORDER BY created_at DESC;

-- Get only published issues in a workspace (for public views)
-- Usage: Replace $1 with workspace ID
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id, parent_comment_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE workspace_id = $1 AND issue_state = 'published'
ORDER BY created_at DESC;

-- Get issues assigned to a user
-- Usage: Replace $1 with user ID
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id, parent_comment_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE assignee_id = $1
ORDER BY created_at DESC;

-- Get issues created by a user
-- Usage: Replace $1 with user ID
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id, parent_comment_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE creator_id = $1
ORDER BY created_at DESC;

-- Get issues in a project
-- Usage: Replace $1 with project ID
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id, parent_comment_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE project_id = $1
ORDER BY created_at DESC;

-- Get issues in a milestone
-- Usage: Replace $1 with milestone ID
SELECT id, public_id, workspace_id, team_id, project_id, milestone_id,
       priority, status, issue_state, title, description, creator_id, parent_issue_id, parent_comment_id,
       due_date, assignee_id, created_at, updated_at
FROM issues 
WHERE milestone_id = $1
ORDER BY created_at DESC;

-- Create new issue
-- Usage: Replace $1-$12 with actual values
INSERT INTO issues (public_id, workspace_id, team_id, project_id, milestone_id, priority, status, issue_state, title, description, creator_id, assignee_id)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
RETURNING id, public_id, workspace_id, team_id, project_id, milestone_id, priority, status, issue_state, title, description, creator_id, assignee_id, created_at, updated_at;

-- Update issue
-- Usage: Replace $1-$9 with new values and issue ID
UPDATE issues 
SET title = $1, description = $2, priority = $3, status = $4, issue_state = $5, assignee_id = $6, due_date = $7, updated_at = NOW()
WHERE id = $8;

-- Publish a draft issue
-- Usage: Replace $1 with issue ID
UPDATE issues 
SET issue_state = 'published', updated_at = NOW()
WHERE id = $1 AND issue_state = 'draft';

-- Archive/unpublish an issue (back to draft)
-- Usage: Replace $1 with issue ID
UPDATE issues 
SET issue_state = 'draft', updated_at = NOW()
WHERE id = $1 AND issue_state = 'published';

-- Get labels for an issue
-- Usage: Replace $1 with issue ID
SELECT il.id, il.workspace_id, il.team_id, il.name, il.color, il.description
FROM issue_labels il
JOIN issue_label_relations ilr ON il.id = ilr.label_id
WHERE ilr.issue_id = $1;

-- Add label to issue
-- Usage: Replace $1 with issue ID, $2 with label ID
INSERT INTO issue_label_relations (issue_id, label_id)
VALUES ($1, $2);

-- Remove label from issue
-- Usage: Replace $1 with issue ID, $2 with label ID
DELETE FROM issue_label_relations 
WHERE issue_id = $1 AND label_id = $2;

-- Get users subscribed to an issue
-- Usage: Replace $1 with issue ID
SELECT u.id, u.username, u.email, u.avatar, u.first_name, u.last_name
FROM users u
JOIN issue_subscriptions isub ON u.id = isub.user_id
WHERE isub.issue_id = $1;

-- Subscribe user to issue
-- Usage: Replace $1 with user ID, $2 with issue ID
INSERT INTO issue_subscriptions (user_id, issue_id)
VALUES ($1, $2);

-- Unsubscribe user from issue
-- Usage: Replace $1 with user ID, $2 with issue ID
DELETE FROM issue_subscriptions 
WHERE user_id = $1 AND issue_id = $2;