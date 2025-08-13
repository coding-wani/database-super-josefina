-- =====================================================
-- 002_create_workspaces.sql
-- TYPE: Foundation Table - Multi-tenancy Root
-- PURPOSE: Top-level containers for data isolation
-- DEPENDENCIES: None (root entity)
-- 
-- DESCRIPTION:
-- Workspaces are the highest level of organization.
-- All data is scoped to a workspace for multi-tenancy.
-- Row-Level Security (RLS) uses workspace_id for isolation.
-- 
-- KEY CONCEPTS:
-- - public_id: Human-readable identifier (e.g., "IW")
-- - All other entities belong to a workspace
-- - Users can be members of multiple workspaces
-- - Workspace switching changes data context
-- 
-- IMPORTANT:
-- Also creates the update_updated_at_column() function
-- used by ALL tables for automatic timestamp updates!
-- 
-- CREATES:
-- - Table: workspaces
-- - Function: update_updated_at_column() (GLOBAL)
-- - Trigger: auto-update updated_at timestamp
-- =====================================================

CREATE TABLE IF NOT EXISTS workspaces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    icon VARCHAR(50),
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create updated_at trigger function (needed for all tables)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_workspaces_updated_at BEFORE UPDATE
    ON workspaces FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();