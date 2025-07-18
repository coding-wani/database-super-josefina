# Todo.md - Database Improvements

## Project Context

The database is designed with PostgreSQL and includes TypeScript types for type safety. The repository is kept separate from the main application for security and maintainability.

## Current Status

✅ **Overall Assessment**: The database schema is production-ready with excellent consistency between SQL and TypeScript types.

## Issues to Fix

### 1. Missing TypeScript Properties

#### 1.1 Add `nextMilestoneNumber` to Project Type

**File**: `types/entities/project.ts`
**Issue**: The SQL schema includes `next_milestone_number` but it's missing from the TypeScript interface
**Fix**: Add the following property to the Project interface:

```typescript
export interface Project {
  // ... existing fields ...
  nextMilestoneNumber: number; // For generating milestone public IDs
  // ... rest of fields ...
}
```

#### 1.2 Clarify Role System Integration

**File**: `types/entities/user.ts`
**Issue**: The new role assignment system (`UserRoleAssignment`) coexists with the legacy `roles` array
**Fix**: Add clarity by updating the User interface:

```typescript
export interface User {
  // ... existing fields ...
  roles?: string[]; // Legacy - Array of role names (consider deprecating)
  roleAssignments?: UserRoleAssignment[]; // New role system (populated via joins)
  // ... rest of fields ...
}
```

#### 1.3 Add Computed Fields to Milestone Type

**File**: `types/entities/milestone.ts`
**Issue**: The `milestone_stats` view provides `progressPercentage` but it's not in the TypeScript type
**Fix**: Add the missing computed field:

```typescript
export interface Milestone {
  // ... existing fields ...
  progressPercentage?: number; // Computed from milestone_stats view
  // ... rest of fields ...
}
```

## Performance Improvements

### 2. Add Missing Database Indexes

**File**: `db/schema/016_create_indexes.sql`
**Purpose**: Improve query performance for common operations
**Add these indexes**:

```sql
-- Index for filtering issues by due date
CREATE INDEX idx_issues_due_date ON issues(due_date) WHERE due_date IS NOT NULL;

-- Index for filtering projects by status
CREATE INDEX idx_projects_status ON projects(status);

-- Composite index for user role lookups
CREATE INDEX idx_user_role_assignments_user_role ON user_role_assignments(user_id, role_id);

-- Index for finding active role assignments
CREATE INDEX idx_user_role_assignments_active ON user_role_assignments(expires_at)
WHERE expires_at IS NULL OR expires_at > NOW();
```

## New Features to Add

### 3. Implement Audit Trail System

**Purpose**: Track all data changes for compliance and debugging
**Create new file**: `db/schema/025_create_audit_log.sql`

```sql
CREATE TABLE IF NOT EXISTS audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    user_id VARCHAR(50) REFERENCES users(id),
    old_data JSONB,
    new_data JSONB,
    changed_fields TEXT[],
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for audit log
CREATE INDEX idx_audit_log_table_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_log_user ON audit_log(user_id);
CREATE INDEX idx_audit_log_created_at ON audit_log(created_at DESC);
CREATE INDEX idx_audit_log_action ON audit_log(action);

-- Generic audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, record_id, action, user_id, new_data)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, current_setting('app.current_user', true), row_to_json(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, record_id, action, user_id, old_data, new_data)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, current_setting('app.current_user', true), row_to_json(OLD), row_to_json(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, record_id, action, user_id, old_data)
        VALUES (TG_TABLE_NAME, OLD.id, TG_OP, current_setting('app.current_user', true), row_to_json(OLD));
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;
```

### 4. Add New API Response Types

**Purpose**: Common query patterns that combine multiple entities
**Location**: Create in `types/api/` directory

#### 4.1 Issue With Details

**Create file**: `types/api/issueWithDetails.ts`

```typescript
import {
  Issue,
  User,
  IssueLabel,
  Comment,
  Link,
  Status,
  Priority,
} from "../index";

export interface IssueWithDetails {
  issue: Issue;
  creator: User;
  assignee?: User;
  labels: IssueLabel[];
  comments: Comment[];
  subscribers: User[];
  links: Link[];
  parentIssue?: Issue;
  subIssues?: Issue[];
  relatedIssues?: Issue[];
}
```

#### 4.2 Project Overview

**Create file**: `types/api/projectOverview.ts`

```typescript
import { Project, User, Team, Milestone, Status, Priority } from "../index";

export interface ProjectOverview {
  project: Project;
  lead?: User;
  team?: Team;
  milestones: Milestone[];
  members: Array<{
    user: User;
    role: string;
  }>;
  issueStats: {
    total: number;
    byStatus: Record<Status, number>;
    byPriority: Record<Priority, number>;
    overdue: number;
    completionRate: number;
  };
  recentActivity: Array<{
    type:
      | "issue_created"
      | "issue_updated"
      | "comment_added"
      | "milestone_completed";
    timestamp: Date;
    userId: string;
    details: any;
  }>;
}
```

#### 4.3 Workspace Analytics

**Create file**: `types/api/workspaceAnalytics.ts`

```typescript
export interface WorkspaceAnalytics {
  workspaceId: string;
  period: {
    start: Date;
    end: Date;
  };
  teamStats: Array<{
    teamId: string;
    teamName: string;
    issueCount: number;
    completionRate: number;
    avgResolutionTime: number;
  }>;
  userStats: Array<{
    userId: string;
    username: string;
    issuesCreated: number;
    issuesResolved: number;
    commentsAdded: number;
  }>;
  trends: {
    issueVelocity: number[]; // Issues per day
    resolutionRate: number[]; // Percentage per day
  };
}
```

## Documentation Improvements

### 5. Add Deletion Strategy Documentation

**File**: Create `db/DELETION_STRATEGY.md`
**Content**:

```markdown
# Database Deletion Strategy

## Cascade Behaviors

### Workspace Deletion

- **Action**: CASCADE
- **Affects**: All child data (teams, projects, issues, comments, etc.)
- **Reason**: Complete workspace removal

### Team Deletion

- **Action**: SET NULL on issues, comments
- **Affects**: Issues retain workspace association but lose team
- **Reason**: Preserve issue history

### User Deletion

- **Action**: RESTRICT (recommended)
- **Affects**: Prevents deletion if user has any data
- **Reason**: Maintain data integrity and audit trail
- **Alternative**: Implement soft delete with `deleted_at` timestamp

### Project Deletion

- **Action**: SET NULL on issues
- **Affects**: Issues become workspace-level
- **Reason**: Preserve issue content

### Issue Deletion

- **Action**: CASCADE to comments, reactions, subscriptions
- **Affects**: All related interaction data
- **Reason**: Clean removal of issue and discussions
```

### 6. Update index.ts Exports

**File**: `types/index.ts`
**Add these exports**:

```typescript
// Add to API Response Types section
export type { IssueWithDetails } from "./api/issueWithDetails";
export type { ProjectOverview } from "./api/projectOverview";
export type { WorkspaceAnalytics } from "./api/workspaceAnalytics";
```

## Testing & Validation

### 7. Create Data Validation Script

**Purpose**: Ensure data consistency across all JSON files
**Create file**: `scripts/validate-data.js`

```javascript
// Script to validate that all UUID references in data files are valid
// Check that all foreign key references exist
// Ensure no orphaned data
// Validate enum values match TypeScript types
```

## Migration Safety

### 8. Add Rollback Scripts

**Purpose**: Safe rollback capability for each migration
**Pattern**: For each schema file, create a corresponding rollback
**Example**: `db/rollback/001_drop_user_roles.sql`

## Security Enhancements

### 9. Add Permission Check Functions

**File**: Create `db/schema/026_create_permission_functions.sql`
**Purpose**: Centralized permission checking

```sql
CREATE OR REPLACE FUNCTION user_has_permission(
    p_user_id VARCHAR(50),
    p_permission VARCHAR(255),
    p_workspace_id UUID DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
    -- Check user permissions based on role assignments
    -- Implementation details here
END;
$$ LANGUAGE plpgsql;
```

## Performance Monitoring

### 10. Add Query Performance Views

**File**: Create `db/schema/027_create_performance_views.sql`
**Purpose**: Monitor slow queries and optimization opportunities

```sql
CREATE VIEW slow_queries AS
SELECT
    query,
    calls,
    total_time,
    mean_time,
    max_time
FROM pg_stat_statements
WHERE mean_time > 100 -- milliseconds
ORDER BY mean_time DESC;
```

## Next Steps Priority Order

1. **High Priority** (Do First):

   - Fix TypeScript type mismatches (items 1.1, 1.2, 1.3)
   - Add missing indexes (item 2)

2. **Medium Priority** (Do Next):

   - Implement audit trail system (item 3)
   - Add new API response types (item 4)
   - Create deletion strategy documentation (item 5)

3. **Low Priority** (Nice to Have):
   - Add validation scripts (item 7)
   - Create rollback scripts (item 8)
   - Add permission functions (item 9)
   - Add performance monitoring (item 10)

## Additional Notes for Next Claude Session

- The database uses PostgreSQL 12+ features (gen_random_uuid(), JSONB, arrays)
- Row Level Security (RLS) is already implemented
- The user ID remains VARCHAR(50) for OAuth compatibility (intentional design)
- All timestamps use triggers for automatic updates
- The schema supports both global and workspace-specific roles
- Sample data files are complete and can be used for testing

## Questions to Consider

1. Should we implement soft deletes instead of hard deletes for users?
2. Do we need file attachment support for issues/comments?
3. Should we add webhook event tracking tables?
4. Do we need time tracking functionality?
5. Should we implement a notification system at the database level?
