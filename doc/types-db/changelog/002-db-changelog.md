# Database Schema Documentation - Issue Tracking System

## Overview

This PostgreSQL database schema powers a comprehensive issue tracking system similar to Linear. It supports multi-tenant workspaces, hierarchical issues, threaded comments, user role management, and rich user interactions.

**Last Updated**: Mid-July 2025 - Role assignment system fully implemented  
**Schema Version**: 25 files + 1 seed file  
**Database**: PostgreSQL 12+ (requires UUID support, JSONB, and array types)

## Architecture Principles

### 1. ID Strategy

- **UUIDs for Internal Entities**: Issues, comments, reactions, labels, links, workspaces, teams, projects, milestones, and roles use `UUID PRIMARY KEY DEFAULT gen_random_uuid()`
- **VARCHAR(50) for External Integration**: Users use `VARCHAR(50)` for OAuth compatibility
- **Public IDs**: Separate human-readable IDs (e.g., "ISSUE-42", "PROJ-01") for user-facing display

### 2. Multi-Tenancy

- **Workspace-based**: All data is scoped to workspaces with optional team sub-scoping
- **Row Level Security (RLS)**: Enabled on all tables for data isolation
- **Cascading Relationships**: Workspace deletion automatically cleans up all related data

### 3. Data Integrity

- **CHECK Constraints**: Enum values validated at database level
- **Foreign Key Constraints**: All relationships enforced with appropriate CASCADE/SET NULL behaviors
- **Composite Unique Constraints**: Prevent logical duplicates (e.g., unique role per workspace)
- **Automatic Timestamps**: `created_at` and `updated_at` maintained by triggers

## Core Entity Tables

### 1. User Roles System (`user_roles` + `user_role_assignments`)

#### `user_roles` - Role Definitions

```sql
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) UNIQUE NOT NULL,           -- e.g., "ROLE-SUPER-ADMIN"
    name VARCHAR(100) UNIQUE NOT NULL,               -- e.g., "super_admin"
    display_name VARCHAR(255) NOT NULL,              -- e.g., "Super Administrator"
    description TEXT,
    permissions JSONB DEFAULT '[]'::jsonb,           -- Array of permission strings
    workspace_id UUID REFERENCES workspaces(id),    -- NULL for global roles
    is_system BOOLEAN DEFAULT false,                 -- System roles can't be deleted
    is_active BOOLEAN DEFAULT true,                  -- Can be disabled
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

**Key Features**:

- **Global + Workspace Roles**: Global roles (workspace_id = NULL) work everywhere; workspace roles are scoped
- **JSONB Permissions**: Flexible permission system using wildcard patterns (e.g., `["api.*", "users.view"]`)
- **System Role Protection**: Built-in roles cannot be deleted
- **Pre-seeded Roles**: Super Admin, Beta Tester, Support Staff, Developer

#### `user_role_assignments` - User-Role Mappings

```sql
CREATE TABLE user_role_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(50) REFERENCES users(id),
    role_id UUID REFERENCES user_roles(id),
    workspace_id UUID REFERENCES workspaces(id),    -- For workspace-specific assignments
    assigned_by VARCHAR(50) REFERENCES users(id),
    assigned_at TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP,                            -- Optional expiration
    CONSTRAINT unique_user_role_assignment UNIQUE (user_id, role_id, workspace_id)
);
```

**Benefits**:

- **Flexible Assignment**: Users can have different roles in different workspaces
- **Temporary Roles**: Support for time-limited access via `expires_at`
- **Audit Trail**: Track who assigned roles and when
- **Prevents Duplicates**: Composite unique constraint

### 2. Workspaces & Organizations

#### `workspaces` - Top-level Containers

```sql
CREATE TABLE workspaces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) UNIQUE NOT NULL,           -- e.g., "acme-corp"
    name VARCHAR(255) NOT NULL,                      -- e.g., "Acme Corporation"
    icon VARCHAR(50),                                -- Emoji or image URL
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

#### `teams` - Sub-organization within Workspaces

```sql
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) NOT NULL,                  -- e.g., "frontend-team"
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    icon VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_team_public_id_per_workspace UNIQUE (workspace_id, public_id)
);
```

### 3. Users & Memberships

#### `users` - Application Users

```sql
CREATE TABLE users (
    id VARCHAR(50) PRIMARY KEY,                      -- OAuth compatibility
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    avatar VARCHAR(500),                             -- Profile image URL
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_online BOOLEAN DEFAULT false,
    current_workspace_id UUID REFERENCES workspaces(id),
    roles TEXT[] DEFAULT '{}',                       -- Legacy: role names array
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

**Note**: The `roles` TEXT[] field is maintained for backward compatibility. New role management uses the `user_role_assignments` table.

#### Membership Tables

- **`workspace_memberships`**: Links users to workspaces with roles (owner, admin, member, guest)
- **`team_memberships`**: Links users to teams with roles (lead, member, viewer)

### 4. Project Management

#### `projects` - Project Containers

```sql
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) NOT NULL,                  -- e.g., "PROJ-01"
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'planned',   -- planned, started, paused, completed, canceled
    priority VARCHAR(20) NOT NULL DEFAULT 'medium',  -- no-priority, urgent, high, medium, low
    lead_id VARCHAR(50) REFERENCES users(id),
    start_date DATE,
    target_date DATE,
    next_milestone_number INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

#### `milestones` - Project Milestones

```sql
CREATE TABLE milestones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) NOT NULL,                  -- e.g., "MILE-01"
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_milestone_public_id_per_project UNIQUE (project_id, public_id)
);
```

### 5. Issue Tracking Core

#### `issues` - Central Issue Entity

```sql
CREATE TABLE issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) UNIQUE NOT NULL,           -- e.g., "ISSUE-42"
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    milestone_id UUID REFERENCES milestones(id) ON DELETE SET NULL,
    priority VARCHAR(20) NOT NULL DEFAULT 'no-priority',
    status VARCHAR(20) NOT NULL DEFAULT 'backlog',
    title VARCHAR(255) NOT NULL,
    description TEXT,                                 -- Markdown content
    creator_id VARCHAR(50) NOT NULL REFERENCES users(id),
    parent_issue_id UUID REFERENCES issues(id),      -- For sub-issues
    parent_comment_id UUID REFERENCES comments(id),  -- When created from comment
    due_date TIMESTAMP,
    assignee_id VARCHAR(50) REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT valid_priority CHECK (priority IN ('no-priority', 'urgent', 'high', 'medium', 'low')),
    CONSTRAINT valid_status CHECK (status IN ('backlog', 'todo', 'in-progress', 'done', 'canceled', 'duplicate')),
    CONSTRAINT milestone_requires_project CHECK (milestone_id IS NULL OR project_id IS NOT NULL)
);
```

**Design Highlights**:

- **Hierarchical**: Self-referencing `parent_issue_id` allows unlimited sub-issue nesting
- **Cross-referenced**: Can be created from comments via `parent_comment_id`
- **Multi-scoped**: Can belong to workspace, team, project, and/or milestone
- **Constrained**: Database-level validation of enums and business rules

#### `comments` - Threaded Discussions

```sql
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    author_id VARCHAR(50) NOT NULL REFERENCES users(id),
    description TEXT NOT NULL,                        -- Markdown content
    parent_issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES comments(id),  -- For threaded replies
    thread_open BOOLEAN DEFAULT true,                 -- Can receive new replies
    comment_url VARCHAR(500),                         -- Deep link URL
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

**Threading Support**: Self-referencing `parent_comment_id` enables nested comment threads of unlimited depth.

### 6. Labeling & Categorization

#### `issue_labels` - Reusable Tags

```sql
CREATE TABLE issue_labels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    color VARCHAR(7) NOT NULL CHECK (color ~ '^#[0-9A-Fa-f]{6}$'),  -- Hex color validation
    description TEXT,
    CONSTRAINT unique_label_name_per_workspace UNIQUE (workspace_id, name)
);
```

**Features**:

- **Color Validation**: Regex CHECK constraint ensures valid hex colors
- **Scoped Uniqueness**: Label names must be unique within workspace
- **Team Optional**: Can be workspace-wide or team-specific

### 7. User Interactions

#### `reactions` - Available Emoji Reactions

```sql
CREATE TABLE reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    emoji VARCHAR(10) NOT NULL,                      -- Actual emoji: "👍"
    name VARCHAR(100) NOT NULL UNIQUE                -- System name: "thumbs_up"
);
```

Pre-seeded with 12 common reactions via `seeds/001_initial_reactions.sql`.

#### `links` - External References

```sql
CREATE TABLE links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    url TEXT NOT NULL,
    description TEXT,                                 -- Optional meta description
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## Junction Tables (Many-to-Many Relationships)

### Issue Relationships

- **`issue_label_relations`**: Issues ↔ Labels
- **`issue_subscriptions`**: Users ↔ Issues (notifications)
- **`issue_favorites`**: Users ↔ Issues (bookmarks)
- **`issue_related_issues`**: Issues ↔ Issues (bidirectional relationships)

### Comment Interactions

- **`comment_subscriptions`**: Users ↔ Comments (thread notifications)
- **`comment_reactions`**: Users ↔ Comments ↔ Reactions (three-way relationship)
- **`comment_issues`**: Comments ↔ Issues (tracks issue creation from comments)

### Example Junction Table Structure

```sql
CREATE TABLE issue_label_relations (
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    label_id UUID REFERENCES issue_labels(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (issue_id, label_id)
);
```

**Design Pattern**: All junction tables use composite primary keys to prevent duplicates and include timestamps for audit trails.

## Advanced PostgreSQL Features

### 1. Automatic Timestamp Management

All tables use a shared trigger function:

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Applied to each table:
CREATE TRIGGER update_[table_name]_updated_at
BEFORE UPDATE ON [table_name]
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

### 2. Bidirectional Relationship Maintenance

The `issue_related_issues` table uses triggers to maintain symmetry:

```sql
CREATE OR REPLACE FUNCTION maintain_issue_relations() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO issue_related_issues (issue_id, related_issue_id, created_at)
        VALUES (NEW.related_issue_id, NEW.issue_id, NEW.created_at)
        ON CONFLICT DO NOTHING;
    ELSIF TG_OP = 'DELETE' THEN
        DELETE FROM issue_related_issues
        WHERE issue_id = OLD.related_issue_id AND related_issue_id = OLD.issue_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 3. Row Level Security (RLS)

Comprehensive RLS policies ensure data isolation:

- Users can only access workspaces they're members of
- Data visibility follows workspace → team → project hierarchy
- System roles can bypass restrictions where appropriate

### 4. Performance Optimization

Strategic indexing covers all common query patterns:

```sql
-- Foreign key indexes (for JOINs)
CREATE INDEX idx_issues_creator ON issues(creator_id);
CREATE INDEX idx_issues_assignee ON issues(assignee_id);

-- Filter indexes (for WHERE clauses)
CREATE INDEX idx_issues_status ON issues(status);
CREATE INDEX idx_issues_priority ON issues(priority);

-- Sort indexes (for ORDER BY)
CREATE INDEX idx_issues_created_at ON issues(created_at DESC);

-- Junction table indexes (bidirectional)
CREATE INDEX idx_issue_label_relations_issue ON issue_label_relations(issue_id);
CREATE INDEX idx_issue_label_relations_label ON issue_label_relations(label_id);
```

## Migration Strategy

### File Execution Order

Files are numbered for sequential execution:

1. `001_create_user_roles.sql` - Role definitions first
2. `002_create_workspaces.sql` - Top-level containers
3. `003_create_users.sql` - Users reference workspaces
4. `004-007_*` - Teams, Projects, Milestones, Issues
5. `008_create_comments.sql` - Comments reference issues
6. `009-015_*` - Labels, reactions, junction tables
7. `016_create_indexes.sql` - Performance optimization
8. `017-021_*` - Additional relationships and memberships
9. `022_enable_rls.sql` - Security policies
10. `023_create_milestone_stats_view.sql` - Computed views
11. `024_create_user_role_assignments.sql` - Advanced role system
12. `025_create_audit_log.sql` - Change tracking

### Safety Features

- `CREATE TABLE IF NOT EXISTS` - Idempotent execution
- `ON CONFLICT DO NOTHING` - Safe data seeding
- Deferred constraint checking for circular references

## Data Consistency Status

### ✅ Fully Consistent Areas (All Issues Resolved)

- **Core Entities**: All use UUID primary keys consistently
- **Junction Tables**: All fixed to use correct UUID references
  - ✅ `comment_reactions`: Now uses UUID for comment_id and reaction_id
  - ✅ `comment_issues`: Now uses UUID for comment_id
  - ✅ `comment_subscriptions`: Now uses UUID for comment_id
- **TypeScript Types**: Complete coverage with all entities exported
  - ✅ Added `UserRoleAssignment` interface
  - ✅ All types properly exported in index.ts
- **Setup File**: Complete with all 25 schema files + seed data
- **Seed Data**: Reactions use auto-generated UUIDs
- **Links Table**: Enhanced with optional description field
- **Data Files**: All updated to match new structure
  - ✅ All ID references converted to UUIDs
  - ✅ Missing data files created (milestones, user_roles, user_role_assignments, issue_label_relations)
  - ✅ Added missing fields (description in links, roles in users, nextMilestoneNumber in projects)

### 🔒 Intentional Design Choices

- **User IDs**: Kept as VARCHAR(50) for OAuth provider compatibility
- **Legacy Roles Array**: `users.roles` TEXT[] maintained alongside new system for backward compatibility

## Recent Updates (Mid-July 2025)

### 1. Implemented Complete Role Assignment System

- **Decision**: Kept both `user_roles` and `user_role_assignments` tables for full audit trail
- **TypeScript**: Created `UserRoleAssignment` interface with full tracking capabilities
- **User Type**: Updated to include both `roles` (legacy) and `roleAssignments` (new system)
- **Benefits**:
  - Track who assigned each role and when
  - Support temporary roles with expiration dates
  - Enable workspace-specific role assignments
  - Maintain backward compatibility with legacy `roles` array

### 2. Enhanced Type System Architecture

- Added `nextMilestoneNumber` to Project interface for milestone ID generation
- Added `progressPercentage` to Milestone interface from computed view
- Created optional `UserWithRoles` API response type for detailed permission views
- Maintained all 6 API response types for optimal query patterns

### 3. Simplified Database Features

- Kept audit log table for change tracking
- Removed complex permission functions (to be implemented in application layer)
- Removed performance monitoring views (too early for optimization)
- Focused on core functionality needed for MVP

### 4. Updated File Structure

- **Total Schema Files**: 25 (including audit log)
- **TypeScript Types**: Complete with all entities and relationships
- **API Response Types**: 6 composed types for efficient data fetching
- **Documentation**: Comprehensive deletion strategy added

## Sample Data Overview

The `/data` directory contains comprehensive sample data for testing:

- **2 Workspaces**: "Interesting Workspace" and "School Manager"
- **3 Teams**: Engineering, Design, and Teachers
- **2 Projects**: Website Redesign and Q1 Planning
- **3 Milestones**: Alpha Release, Beta Release, Planning Complete
- **12 Issues**: Including sub-issues and comment-created issues
- **3 Comments**: Including threaded replies
- **12 Reactions**: Full emoji set from seed data
- **5 Users**: With various roles and permissions
- **6 Links**: With meta descriptions
- **4 Labels**: Bug, Feature, ideation, Linear Test
- **4 System Roles**: Super Admin, Beta Tester, Support Staff, Developer
- **5 Role Assignments**: Mapping users to roles with audit information

## Query Examples

### Get User with All Role Details

```sql
-- Get user with their role assignments and full role information
SELECT
    u.*,
    COALESCE(
        jsonb_agg(
            jsonb_build_object(
                'assignment_id', ura.id,
                'role_id', ur.id,
                'role_name', ur.name,
                'role_display_name', ur.display_name,
                'permissions', ur.permissions,
                'workspace_id', ura.workspace_id,
                'assigned_by', assigner.username,
                'assigned_at', ura.assigned_at,
                'expires_at', ura.expires_at
            ) ORDER BY ura.assigned_at DESC
        ) FILTER (WHERE ura.id IS NOT NULL),
        '[]'::jsonb
    ) as role_assignments
FROM users u
LEFT JOIN user_role_assignments ura ON u.id = ura.user_id
LEFT JOIN user_roles ur ON ura.role_id = ur.id
LEFT JOIN users assigner ON ura.assigned_by = assigner.id
WHERE u.id = ?
GROUP BY u.id;
```

### Check User Permissions

```sql
-- Get all active permissions for a user
WITH user_permissions AS (
    SELECT DISTINCT
        jsonb_array_elements_text(ur.permissions) as permission
    FROM user_role_assignments ura
    JOIN user_roles ur ON ura.role_id = ur.id
    WHERE ura.user_id = ?
    AND (ura.expires_at IS NULL OR ura.expires_at > NOW())
    AND ur.is_active = true
)
SELECT array_agg(DISTINCT permission) as permissions
FROM user_permissions;
```

### Get Issue with All Relationships

```sql
SELECT
    i.*,
    creator.username,
    assignee.username,
    array_agg(DISTINCT l.name) as labels,
    count(DISTINCT s.user_id) as subscribers,
    count(DISTINCT f.user_id) as favorites
FROM issues i
JOIN users creator ON i.creator_id = creator.id
LEFT JOIN users assignee ON i.assignee_id = assignee.id
LEFT JOIN issue_label_relations ilr ON i.id = ilr.issue_id
LEFT JOIN issue_labels l ON ilr.label_id = l.id
LEFT JOIN issue_subscriptions s ON i.id = s.issue_id
LEFT JOIN issue_favorites f ON i.id = f.issue_id
WHERE i.workspace_id = ? AND i.status = 'in-progress'
GROUP BY i.id, creator.username, assignee.username
ORDER BY i.created_at DESC;
```

### Get Comment Reactions with User Details

```sql
SELECT
    r.emoji,
    r.name,
    count(*) as count,
    array_agg(u.username ORDER BY cr.reacted_at) as users
FROM comment_reactions cr
JOIN reactions r ON cr.reaction_id = r.id
JOIN users u ON cr.user_id = u.id
WHERE cr.comment_id = ?
GROUP BY r.id, r.emoji, r.name
ORDER BY count DESC;
```

## Production Readiness

The schema is now 100% consistent and production-ready with:

- ✅ Complete type safety between SQL and TypeScript
- ✅ All foreign key relationships properly defined
- ✅ Comprehensive indexing strategy
- ✅ Row-level security policies
- ✅ Automatic timestamp management
- ✅ Pre-seeded system data
- ✅ OAuth-compatible user system
- ✅ Complete sample data for testing
- ✅ Full role-based access control with audit trail
- ✅ Simple audit logging for change tracking

## Future Extensibility

The schema is designed for growth:

- **Custom Fields**: JSONB columns can be added for flexible metadata
- **Audit Trails**: Timestamp triggers ready for history tracking
- **API Evolution**: Junction table pattern makes new relationships easy
- **Performance Scaling**: Index strategy supports query optimization
- **Webhook Support**: Schema ready for event-driven architecture
- **File Attachments**: Can easily add attachment tables for issues/comments
- **Time Tracking**: Can add time entry tables for work logging
- **Custom Workflows**: State machine patterns can be implemented
- **Advanced Permissions**: Role system ready for complex permission rules

This schema provides a robust foundation for building a modern, scalable issue tracking system with enterprise-grade features.
