-- =====================================================
-- 016_create_indexes.sql
-- TYPE: Performance Optimization
-- PURPOSE: Create additional indexes for query performance
-- DEPENDENCIES: All tables must exist before indexes
-- 
-- DESCRIPTION:
-- Additional indexes beyond those in table definitions.
-- Optimizes common query patterns and joins.
-- Includes partial indexes for filtered queries.
-- 
-- INDEX STRATEGY:
-- - Foreign keys: Always index for JOIN performance
-- - Status/State: For filtering and grouping
-- - Dates: For chronological queries
-- - Partial: For NULL checks (WHERE clause)
-- 
-- PERFORMANCE IMPACT:
-- - Speeds up SELECT queries
-- - Slows down INSERT/UPDATE slightly
-- - Trade-off: Read vs Write performance
-- - Monitor with EXPLAIN ANALYZE
-- 
-- CREATES:
-- - 30+ indexes across all tables
-- - Partial indexes for NULL columns
-- - Composite indexes for common filters
-- =====================================================

-- Issues indexes
CREATE INDEX IF NOT EXISTS idx_issues_creator ON issues(creator_id);
CREATE INDEX IF NOT EXISTS idx_issues_assignee ON issues(assignee_id);
CREATE INDEX IF NOT EXISTS idx_issues_parent_issue ON issues(parent_issue_id);
CREATE INDEX IF NOT EXISTS idx_issues_status ON issues(status);
CREATE INDEX IF NOT EXISTS idx_issues_priority ON issues(priority);
CREATE INDEX IF NOT EXISTS idx_issues_created_at ON issues(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_issues_due_date ON issues(due_date) WHERE due_date IS NOT NULL;

-- Milestone indexes
CREATE INDEX IF NOT EXISTS idx_issues_milestone ON issues(milestone_id);
CREATE INDEX IF NOT EXISTS idx_issues_status_milestone ON issues(milestone_id, status);  -- For counting by status
CREATE INDEX IF NOT EXISTS idx_milestones_public_id ON milestones(public_id);

-- Comments indexes
CREATE INDEX IF NOT EXISTS idx_comments_author ON comments(author_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent_issue ON comments(parent_issue_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent_comment ON comments(parent_comment_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at DESC);

-- Issue subscriptions indexes
CREATE INDEX IF NOT EXISTS idx_issue_subscriptions_issue ON issue_subscriptions(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_subscriptions_user ON issue_subscriptions(user_id);

-- Comment subscriptions indexes
CREATE INDEX IF NOT EXISTS idx_comment_subscriptions_comment ON comment_subscriptions(comment_id);
CREATE INDEX IF NOT EXISTS idx_comment_subscriptions_user ON comment_subscriptions(user_id);

-- Issue favorites indexes
CREATE INDEX IF NOT EXISTS idx_issue_favorites_issue ON issue_favorites(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_favorites_user ON issue_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_issue_favorites_date ON issue_favorites(favorited_at DESC);

-- Comment reactions indexes
CREATE INDEX IF NOT EXISTS idx_comment_reactions_comment ON comment_reactions(comment_id);
CREATE INDEX IF NOT EXISTS idx_comment_reactions_user ON comment_reactions(user_id);
CREATE INDEX IF NOT EXISTS idx_comment_reactions_reaction ON comment_reactions(reaction_id);

-- Issue label relations indexes
CREATE INDEX IF NOT EXISTS idx_issue_label_relations_issue ON issue_label_relations(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_label_relations_label ON issue_label_relations(label_id);

-- Links indexes
CREATE INDEX IF NOT EXISTS idx_links_issue ON links(issue_id);
CREATE INDEX IF NOT EXISTS idx_links_created_at ON links(created_at DESC);

-- Related issues indexes
CREATE INDEX IF NOT EXISTS idx_issue_related_issues_issue ON issue_related_issues(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_related_issues_related ON issue_related_issues(related_issue_id);

-- Projects indexes
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_priority ON projects(priority);