-- Migration: Convert all TIMESTAMP fields to TIMESTAMPTZ for proper timezone support
-- This ensures all datetime values are stored with timezone information

-- Workspaces
ALTER TABLE workspaces 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

-- Users
ALTER TABLE users 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

-- Teams
ALTER TABLE teams 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

-- Projects (already handled start_date and target_date in schema update)
ALTER TABLE projects 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

-- Milestones
ALTER TABLE milestones 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

-- Issues
ALTER TABLE issues 
  ALTER COLUMN due_date TYPE TIMESTAMPTZ,
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

-- Comments
ALTER TABLE comments 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

-- Issue Labels
ALTER TABLE issue_labels 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

-- Reactions
ALTER TABLE reactions 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

-- Links
ALTER TABLE links 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

-- User Roles
ALTER TABLE user_roles 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

-- User Role Assignment Events
ALTER TABLE user_role_assignment_events 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN expires_at TYPE TIMESTAMPTZ;

-- Junction tables with timestamps
ALTER TABLE issue_label_relations 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ;

ALTER TABLE issue_subscriptions 
  ALTER COLUMN subscribed_at TYPE TIMESTAMPTZ;

ALTER TABLE comment_subscriptions 
  ALTER COLUMN subscribed_at TYPE TIMESTAMPTZ;

ALTER TABLE issue_favorites 
  ALTER COLUMN favorited_at TYPE TIMESTAMPTZ;

ALTER TABLE comment_reactions 
  ALTER COLUMN reacted_at TYPE TIMESTAMPTZ;

ALTER TABLE comment_issues 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ;

ALTER TABLE issue_related_issues 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ;

ALTER TABLE workspace_memberships 
  ALTER COLUMN joined_at TYPE TIMESTAMPTZ;

ALTER TABLE team_memberships 
  ALTER COLUMN joined_at TYPE TIMESTAMPTZ;

-- Update the trigger function to use TIMESTAMPTZ
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW(); -- NOW() returns TIMESTAMPTZ
    RETURN NEW;
END;
$$ language 'plpgsql';