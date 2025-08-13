-- =====================================================
-- 014_create_issue_favorites.sql
-- TYPE: Junction Table - User Bookmarking
-- PURPOSE: Personal issue bookmarking/starring system
-- DEPENDENCIES:
--   - 003_create_users.sql (user_id reference)
--   - 007_create_issues.sql (issue_id reference)
-- 
-- DESCRIPTION:
-- Allows users to favorite/star issues.
-- Personal organization tool (like bookmarks).
-- Different from subscriptions (visual vs notifications).
-- 
-- KEY CONCEPTS:
-- - Personal quick access list
-- - No notifications (unlike subscriptions)
-- - Appears in user's favorites view
-- - Can favorite without subscribing
-- 
-- UI FEATURES:
-- - Star icon on issue cards
-- - Favorites sidebar/dashboard
-- - Quick filters for starred items
-- - Sort by favorited_at date
-- 
-- CREATES:
-- - Table: issue_favorites
-- - Composite primary key (user_id, issue_id)
-- =====================================================

CREATE TABLE IF NOT EXISTS issue_favorites (
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    favorited_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, issue_id)
);