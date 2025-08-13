-- =====================================================
-- 015_create_comment_reactions.sql
-- TYPE: Junction Table - Reaction Assignments
-- PURPOSE: Track emoji reactions on comments
-- DEPENDENCIES:
--   - 003_create_users.sql (user_id reference)
--   - 008_create_comments.sql (comment_id reference)
--   - 010_create_reactions.sql (reaction_id reference)
-- 
-- DESCRIPTION:
-- Links users, comments, and reactions.
-- One user can have one of each reaction type per comment.
-- Aggregated for display (e.g., "👍 5").
-- 
-- KEY CONCEPTS:
-- - Ternary relationship (user-comment-reaction)
-- - Primary key prevents duplicate reactions
-- - reacted_at for chronological sorting
-- - Basis for reaction animations/notifications
-- 
-- REACTION RULES:
-- - User can add multiple different reactions
-- - Cannot duplicate same reaction
-- - Can remove and re-add reactions
-- - Count aggregated in API responses
-- 
-- CREATES:
-- - Table: comment_reactions
-- - Composite primary key (user_id, comment_id, reaction_id)
-- =====================================================

CREATE TABLE IF NOT EXISTS comment_reactions (
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    reaction_id UUID REFERENCES reactions(id) ON DELETE CASCADE,
    reacted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, comment_id, reaction_id)
);