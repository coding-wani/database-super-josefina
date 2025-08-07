# Database Deletion Strategy

This document outlines the deletion behavior for all entities in this App project database. Understanding these behaviors is crucial for maintaining data integrity and preventing accidental data loss.

## Overview

The database uses a combination of CASCADE, SET NULL, and RESTRICT foreign key constraints to handle deletions appropriately based on business logic requirements.

## Cascade Behaviors by Entity

### Workspace Deletion

- **Action**: CASCADE
- **Affects**:
  - All teams within the workspace
  - All projects (workspace-level and team-level)
  - All issues and their comments
  - All labels (workspace and team-scoped)
  - All workspace memberships
  - All links associated with issues
- **Reason**: Complete workspace removal - when a workspace is deleted, all contained data should be removed
- **Warning**: This is a destructive operation that cannot be undone

### Team Deletion

- **Action**: SET NULL on issues, comments, and projects
- **Affects**:
  - Issues: `team_id` becomes NULL (issues remain at workspace level)
  - Comments: `team_id` becomes NULL
  - Projects: `team_id` becomes NULL (become workspace-level projects)
  - Team memberships: CASCADE (removed)
  - Team-specific labels: SET NULL (become workspace labels)
- **Reason**: Preserve issue and project history while removing team association
- **Use Case**: Team reorganization without losing work history

### User Deletion

- **Current Action**: No constraint (allows deletion)
- **Recommended Action**: RESTRICT or implement soft delete
- **Affects if deleted**:
  - Created issues remain (creator_id preserved)
  - Assigned issues: assignee_id should be SET NULL
  - Comments remain (author_id preserved)
  - Workspace/team memberships: CASCADE
- **Reason**: Maintain audit trail and content integrity
- **Recommended Implementation**:
  ```sql
  ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP;
  ALTER TABLE users ADD COLUMN deletion_reason TEXT;
  -- Create partial unique index for soft deletes
  CREATE UNIQUE INDEX users_email_unique_active
  ON users(email) WHERE deleted_at IS NULL;
  ```

### Project Deletion

- **Action**: SET NULL on issues, CASCADE on milestones
- **Affects**:
  - Issues: `project_id` becomes NULL (remain at workspace/team level)
  - Milestones: CASCADE (completely removed)
  - Project lead assignment cleared
- **Reason**: Preserve issue content while removing project structure
- **Use Case**: Project cancellation without losing issue history

### Milestone Deletion

- **Action**: SET NULL on issues
- **Affects**:
  - Issues: `milestone_id` becomes NULL
  - Milestone statistics are recalculated
- **Reason**: Issues should not be deleted when reorganizing milestones
- **Use Case**: Milestone restructuring

### Issue Deletion

- **Action**: CASCADE to most relationships
- **Affects**:
  - Comments: CASCADE (all comments on the issue are deleted)
  - Sub-issues: Depends on business logic
    - Option 1: CASCADE (delete all sub-issues)
    - Option 2: SET NULL on parent_issue_id (orphan sub-issues)
  - Reactions: CASCADE (via comment_reactions)
  - Subscriptions: CASCADE
  - Favorites: CASCADE
  - Links: CASCADE
  - Related issues: CASCADE (both directions cleaned up by trigger)
- **Reason**: Complete removal of issue and all discussions
- **Warning**: This removes all comment history

### Comment Deletion

- **Action**: CASCADE to reactions and subscriptions
- **Affects**:
  - Child comments: CASCADE or SET NULL (depends on threading requirements)
  - Reactions: CASCADE
  - Subscriptions: CASCADE
  - Issues created from comment: parent_comment_id SET NULL
- **Reason**: Clean removal of comment and interactions

### Label Deletion

- **Action**: CASCADE from issue_label_relations
- **Affects**:
  - Issue associations: CASCADE (labels removed from issues)
  - Label statistics need recalculation
- **Reason**: Labels are metadata that can be safely removed

## Implementation Guidelines

### 1. Before Implementing Deletions

Always check for:

- Active references to the entity
- Impact on reporting and analytics
- Audit requirements
- User notifications needed

### 2. Soft Delete Pattern

For entities requiring audit trails:

```sql
-- Add soft delete columns
ALTER TABLE [table_name] ADD COLUMN deleted_at TIMESTAMP;
ALTER TABLE [table_name] ADD COLUMN deleted_by VARCHAR(50) REFERENCES users(id);
ALTER TABLE [table_name] ADD COLUMN deletion_reason TEXT;

-- Update RLS policies to exclude soft-deleted records
CREATE POLICY exclude_deleted ON [table_name]
  FOR SELECT
  USING (deleted_at IS NULL);
```

### 3. Deletion Checks

Implement pre-deletion checks:

```sql
CREATE OR REPLACE FUNCTION check_safe_to_delete_user(p_user_id VARCHAR(50))
RETURNS BOOLEAN AS $$
DECLARE
    active_issues_count INT;
    recent_activity BOOLEAN;
BEGIN
    -- Check for assigned issues
    SELECT COUNT(*) INTO active_issues_count
    FROM issues
    WHERE assignee_id = p_user_id
    AND status NOT IN ('done', 'canceled');

    -- Check for recent activity (last 30 days)
    SELECT EXISTS(
        SELECT 1 FROM comments
        WHERE author_id = p_user_id
        AND created_at > NOW() - INTERVAL '30 days'
    ) INTO recent_activity;

    RETURN active_issues_count = 0 AND NOT recent_activity;
END;
$$ LANGUAGE plpgsql;
```

### 4. Cascade Protection

For production environments, consider adding deletion protection:

```sql
CREATE OR REPLACE FUNCTION prevent_cascade_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_TABLE_NAME = 'workspaces' THEN
        -- Check if workspace has significant data
        IF EXISTS(SELECT 1 FROM issues WHERE workspace_id = OLD.id LIMIT 100) THEN
            RAISE EXCEPTION 'Cannot delete workspace with more than 100 issues. Archive instead.';
        END IF;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER protect_workspace_deletion
BEFORE DELETE ON workspaces
FOR EACH ROW EXECUTE FUNCTION prevent_cascade_delete();
```

## Best Practices

1. **Always backup** before bulk deletions
2. **Use transactions** for complex deletions
3. **Log all deletions** to the audit_log table
4. **Notify affected users** before deletion
5. **Implement "trash/recycle bin"** for user-initiated deletions
6. **Set up alerts** for unusual deletion patterns

## Recovery Procedures

### Accidental Deletion Recovery

1. Check audit_log for deletion record
2. Use the stored JSONB data to reconstruct records
3. Restore in correct order (respect foreign keys)
4. Update any cached data or search indexes

### Example Recovery Query

```sql
-- Recover a deleted issue from audit log
WITH deleted_issue AS (
    SELECT old_data
    FROM audit_log
    WHERE table_name = 'issues'
    AND action = 'DELETE'
    AND record_id = '[issue_id]'
    ORDER BY created_at DESC
    LIMIT 1
)
INSERT INTO issues
SELECT * FROM jsonb_populate_record(null::issues,
    (SELECT old_data FROM deleted_issue)
);
```

## Monitoring

Set up monitoring for:

- Cascade deletion chains exceeding threshold
- Bulk deletions (>10 records at once)
- Deletions by non-admin users
- Orphaned records after SET NULL operations
