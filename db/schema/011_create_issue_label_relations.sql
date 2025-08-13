-- =====================================================
-- 011_create_issue_label_relations.sql
-- TYPE: Junction Table - Many-to-Many Relationship
-- PURPOSE: Link issues to labels
-- DEPENDENCIES:
--   - 007_create_issues.sql (issue_id reference)
--   - 009_create_issue_labels.sql (label_id reference)
-- 
-- DESCRIPTION:
-- Junction table for many-to-many relationship.
-- Issues can have multiple labels.
-- Labels can be on multiple issues.
-- 
-- KEY CONCEPTS:
-- - No additional data needed (pure relationship)
-- - Primary key prevents duplicate assignments
-- - Cascade delete maintains referential integrity
-- - created_at tracks when label was added
-- 
-- CREATES:
-- - Table: issue_label_relations
-- - Composite primary key (issue_id, label_id)
-- =====================================================

CREATE TABLE IF NOT EXISTS issue_label_relations (
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    label_id UUID REFERENCES issue_labels(id) ON DELETE CASCADE,  -- Changed to UUID
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (issue_id, label_id)
);