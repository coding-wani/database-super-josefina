-- =====================================================
-- 013_create_comment_subscriptions.sql
-- TYPE: Junction Table - User-Comment Relationship
-- PURPOSE: Track thread-level notification preferences
-- DEPENDENCIES:
--   - 003_create_users.sql (user_id reference)
--   - 008_create_comments.sql (comment_id reference)
-- 
-- DESCRIPTION:
-- Allows users to follow specific comment threads.
-- More granular than issue subscriptions.
-- Currently unused (placeholder for future feature).
-- 
-- KEY CONCEPTS:
-- - Thread-level notifications
-- - Different from issue subscriptions
-- - Useful for long discussion threads
-- - Reduces notification noise
-- 
-- FUTURE USE CASES:
-- - Subscribe to specific discussion thread
-- - Mute noisy threads while following issue
-- - Notify only on direct replies
-- 
-- CREATES:
-- - Table: comment_subscriptions
-- - Composite primary key (user_id, comment_id)
-- =====================================================

CREATE TABLE IF NOT EXISTS comment_subscriptions (
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    subscribed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, comment_id)
);