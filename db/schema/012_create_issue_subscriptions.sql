-- =====================================================
-- 012_create_issue_subscriptions.sql
-- TYPE: Junction Table - User-Issue Relationship
-- PURPOSE: Track which users follow issues for notifications
-- DEPENDENCIES:
--   - 003_create_users.sql (user_id reference)
--   - 007_create_issues.sql (issue_id reference)
-- 
-- DESCRIPTION:
-- Tracks user subscriptions to issues.
-- Subscribers get notified of updates.
-- Separate from assignee/creator relationships.
-- 
-- KEY CONCEPTS:
-- - Explicit opt-in for notifications
-- - Different from favorites (notification vs bookmark)
-- - Auto-subscribe options (creator, assignee, mentioned)
-- - Foundation for notification system
-- 
-- NOTIFICATION TRIGGERS:
-- - Status changes
-- - New comments
-- - Assignment changes
-- - Due date updates
-- 
-- CREATES:
-- - Table: issue_subscriptions
-- - Composite primary key (user_id, issue_id)
-- =====================================================

CREATE TABLE IF NOT EXISTS issue_subscriptions (
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    subscribed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, issue_id)
);