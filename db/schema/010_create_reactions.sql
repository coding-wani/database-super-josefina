-- =====================================================
-- 010_create_reactions.sql
-- TYPE: Reference Table - Emoji Library
-- PURPOSE: Define available emoji reactions for comments
-- DEPENDENCIES:
--   - Function: update_updated_at_column() from 002
-- 
-- DESCRIPTION:
-- Central repository of available emoji reactions.
-- Used by comment_reactions junction table.
-- Standardizes reaction options across the system.
-- 
-- KEY CONCEPTS:
-- - emoji: The actual emoji character (🥰)
-- - name: Unique identifier (heart_eyes)
-- - System-wide (not workspace-scoped)
-- - Extensible (can add more reactions)
-- 
-- REACTION USES:
-- - Quick feedback on comments
-- - Non-verbal communication
-- - Sentiment analysis
-- - Engagement metrics
-- 
-- CREATES:
-- - Table: reactions
-- - Trigger: auto-update updated_at timestamp
-- - Unique constraint on name
-- =====================================================

CREATE TABLE IF NOT EXISTS reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- Auto-generated UUID
    emoji VARCHAR(10) NOT NULL,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_reactions_updated_at BEFORE UPDATE
    ON reactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();