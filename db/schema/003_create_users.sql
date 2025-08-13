-- =====================================================
-- 003_create_users.sql
-- TYPE: Foundation Table - Authentication/Identity
-- PURPOSE: Store user accounts and authentication data
-- DEPENDENCIES:
--   - 002_create_workspaces.sql (for current_workspace_id)
--   - Function: update_updated_at_column() from 002
-- 
-- DESCRIPTION:
-- Core user table for authentication and identity.
-- Uses VARCHAR(50) ID for OAuth provider compatibility.
-- Tracks online status and current workspace context.
-- 
-- KEY CONCEPTS:
-- - id: VARCHAR(50) NOT UUID for OAuth compatibility
-- - roles: Array of role names for quick permission checks
-- - current_workspace_id: Last active workspace
-- - is_online: Real-time presence indicator
-- 
-- OAUTH COMPATIBILITY:
-- The VARCHAR(50) ID allows storing OAuth provider IDs like:
-- - "google|123456789"
-- - "github|username"
-- - "auth0|5f7c8ec7c33c6c004bbafe82"
-- 
-- CREATES:
-- - Table: users
-- - Trigger: auto-update updated_at timestamp
-- =====================================================

CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(50) PRIMARY KEY,  -- Kept as VARCHAR(50) for OAuth compatibility
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    avatar VARCHAR(500),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_online BOOLEAN NOT NULL DEFAULT false,  -- Made NOT NULL with default
    current_workspace_id UUID REFERENCES workspaces(id),
    roles TEXT[] DEFAULT '{}',  -- Array of role names/IDs
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_users_updated_at BEFORE UPDATE
    ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();