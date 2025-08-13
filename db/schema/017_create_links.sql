-- =====================================================
-- 017_create_links.sql
-- TYPE: Extension Table - External References
-- PURPOSE: Attach external URLs to issues
-- DEPENDENCIES:
--   - 002_create_workspaces.sql (workspace_id for RLS)
--   - 007_create_issues.sql (issue_id reference)
--   - Function: update_updated_at_column() from 002
-- 
-- DESCRIPTION:
-- Store external links related to issues.
-- Can extract metadata from URLs.
-- Used for documentation, references, resources.
-- 
-- KEY CONCEPTS:
-- - One issue can have multiple links
-- - Title/description from meta tags or manual
-- - Workspace-scoped for RLS
-- - Common for research/documentation issues
-- 
-- LINK TYPES (by convention):
-- - Documentation
-- - Design mockups
-- - Customer requests
-- - Bug reports
-- - Related articles
-- 
-- CREATES:
-- - Table: links
-- - Indexes: workspace, issue, chronological
-- - Trigger: auto-update updated_at timestamp
-- =====================================================

CREATE TABLE IF NOT EXISTS links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- Changed to UUID
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    url TEXT NOT NULL,
    description TEXT,  -- Optional description from meta tags or user input
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_links_workspace ON links(workspace_id);
CREATE INDEX IF NOT EXISTS idx_links_issue ON links(issue_id);
CREATE INDEX IF NOT EXISTS idx_links_created_at ON links(created_at DESC);

CREATE TRIGGER update_links_updated_at BEFORE UPDATE
    ON links FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();