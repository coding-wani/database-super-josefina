-- =====================================================
-- 008_create_comments.sql
-- TYPE: Core Content Table - Communication
-- PURPOSE: Threaded discussions on issues
-- DEPENDENCIES:
--   - 002_create_workspaces.sql (workspace_id for RLS)
--   - 003_create_users.sql (author_id)
--   - 004_create_teams.sql (optional team_id)
--   - 007_create_issues.sql (parent_issue_id required)
--   - Function: update_updated_at_column() from 002
-- 
-- DESCRIPTION:
-- Comments enable team discussion on issues.
-- Support threaded replies (parent_comment_id).
-- Include reactions via junction table.
-- 
-- KEY CONCEPTS:
-- - Threaded: Comments can reply to other comments
-- - thread_open: Controls if replies are allowed
-- - comment_url: Deep linking for notifications
-- - Markdown support in description
-- 
-- COMMENT FEATURES:
-- - Mentions (@username)
-- - Reactions (emoji via comment_reactions)
-- - Subscriptions for notifications
-- - Edit history (via updated_at)
-- 
-- CREATES:
-- - Table: comments
-- - Indexes: workspace, team, author, issue, thread
-- - Trigger: auto-update updated_at timestamp
-- =====================================================

CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- Changed to UUID
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    author_id VARCHAR(50) NOT NULL REFERENCES users(id),
    description TEXT NOT NULL,
    parent_issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES comments(id),  -- Changed to UUID
    thread_open BOOLEAN NOT NULL DEFAULT true,  -- Made NOT NULL with default
    comment_url VARCHAR(500) NOT NULL,  -- Made NOT NULL - required for sharing
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_comments_workspace ON comments(workspace_id);
CREATE INDEX idx_comments_team ON comments(team_id);
CREATE INDEX idx_comments_author ON comments(author_id);
CREATE INDEX idx_comments_parent_issue ON comments(parent_issue_id);
CREATE INDEX idx_comments_parent_comment ON comments(parent_comment_id);
CREATE INDEX idx_comments_created_at ON comments(created_at DESC);

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE
    ON comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();