-- Enable RLS on all tables
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE workspace_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE milestones ENABLE ROW LEVEL SECURITY;

-- Workspace access policy
CREATE POLICY workspace_access ON workspaces
  FOR ALL
  USING (
    id IN (
      SELECT workspace_id 
      FROM workspace_memberships 
      WHERE user_id = current_setting('app.current_user')::text
    )
  );

-- Team access policy
CREATE POLICY team_access ON teams
  FOR ALL
  USING (
    workspace_id IN (
      SELECT workspace_id 
      FROM workspace_memberships 
      WHERE user_id = current_setting('app.current_user')::text
    )
  );

-- Project access policy
CREATE POLICY project_access ON projects
  FOR ALL
  USING (
    -- User must be in the workspace
    workspace_id IN (
      SELECT workspace_id 
      FROM workspace_memberships 
      WHERE user_id = current_setting('app.current_user')::text
    )
    AND (
      -- If project has no team, workspace access is enough
      team_id IS NULL
      OR
      -- If project has team, user must be team member
      team_id IN (
        SELECT team_id 
        FROM team_memberships 
        WHERE user_id = current_setting('app.current_user')::text
      )
    )
  );

-- Issue access policy
CREATE POLICY issue_access ON issues
  FOR ALL
  USING (
    -- User must be in the workspace
    workspace_id IN (
      SELECT workspace_id 
      FROM workspace_memberships 
      WHERE user_id = current_setting('app.current_user')::text
    )
    AND (
      -- If issue has no team, workspace access is enough
      team_id IS NULL
      OR
      -- If issue has team, user must be team member
      team_id IN (
        SELECT team_id 
        FROM team_memberships 
        WHERE user_id = current_setting('app.current_user')::text
      )
    )
  );

-- ADD THIS NEW MILESTONE POLICY:
-- Milestone access policy
-- Milestones inherit access from their parent project
CREATE POLICY milestone_access ON milestones
  FOR ALL
  USING (
    project_id IN (
      SELECT p.id
      FROM projects p
      WHERE p.workspace_id IN (
        SELECT workspace_id 
        FROM workspace_memberships 
        WHERE user_id = current_setting('app.current_user')::text
      )
      AND (
        p.team_id IS NULL
        OR
        p.team_id IN (
          SELECT team_id 
          FROM team_memberships 
          WHERE user_id = current_setting('app.current_user')::text
        )
      )
    )
  );