# �� Critical Inconsistencies Between TypeScript Types and SQL Schema

This document outlines all critical inconsistencies found between the TypeScript type definitions in `/types/` and the SQL schema files in `/db/schema/`. These inconsistencies could cause runtime errors and database failures.

## 📋 Summary

- **6 Critical ID Type Mismatches** - UUID vs VARCHAR(50) inconsistencies
- **1 Missing Database Column** - User roles field not implemented in SQL
- **Multiple Foreign Key Reference Issues** - Due to ID type mismatches

## 🔴 Critical Issues

### 1. User ID Type Mismatch

**Location**:

- TypeScript: `types/entities/user.ts`
- SQL: `db/schema/002_create_users.sql`

**Issue**:

- TypeScript expects `User.id` to be a UUID (string)
- SQL defines `users.id` as `VARCHAR(50)`

**Impact**:

- All foreign key references to users will fail
- Affects: workspace_memberships, team_memberships, issues, comments, projects, etc.

**TypeScript Definition**:

```typescript
export interface User {
  id: string; // Should be UUID but SQL uses VARCHAR(50)
  // ... other fields
}
```

**SQL Definition**:

```sql
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(50) PRIMARY KEY, -- Should be UUID to match other tables
    -- ... other fields
);
```

**Fix Required**: Change SQL to use UUID:

```sql
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- ... other fields
);
```

---

### 2. Comment ID Type Mismatch

**Location**:

- TypeScript: `types/entities/comment.ts`
- SQL: `db/schema/007_create_comments.sql`

**Issue**:

- TypeScript expects `Comment.id` to be a UUID (string)
- SQL defines `comments.id` as `VARCHAR(50)`

**Impact**:

- Foreign key references in issues table will fail
- Comment relationships will break

**TypeScript Definition**:

```typescript
export interface Comment {
  id: string; // Should be UUID but SQL uses VARCHAR(50)
  // ... other fields
}
```

**SQL Definition**:

```sql
CREATE TABLE IF NOT EXISTS comments (
    id VARCHAR(50) PRIMARY KEY, -- Should be UUID to match other tables
    -- ... other fields
);
```

**Fix Required**: Change SQL to use UUID:

```sql
CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- ... other fields
);
```

---

### 3. Missing User Roles Column

**Location**:

- TypeScript: `types/entities/user.ts`
- SQL: `db/schema/002_create_users.sql`

**Issue**:

- TypeScript defines `User.roles` as `string[]` (PostgreSQL TEXT[] array)
- SQL has no `roles` column in the users table

**Impact**:

- Application will fail when trying to access user roles
- Role-based functionality will break

**TypeScript Definition**:

```typescript
export interface User {
  // ... other fields
  roles?: string[]; // Array of user roles (PostgreSQL TEXT[] array)
  // ... other fields
}
```

**SQL Definition**:

```sql
CREATE TABLE IF NOT EXISTS users (
    -- ... other fields
    -- MISSING: roles TEXT[] column
    -- ... other fields
);
```

**Fix Required**: Add roles column to SQL:

```sql
CREATE TABLE IF NOT EXISTS users (
    -- ... other fields
    roles TEXT[] DEFAULT '{}',
    -- ... other fields
);
```

---

### 4. Reaction ID Type Mismatch

**Location**:

- TypeScript: `types/entities/reaction.ts`
- SQL: `db/schema/009_create_reactions.sql`

**Issue**:

- TypeScript expects `Reaction.id` to be a UUID (string)
- SQL defines `reactions.id` as `VARCHAR(50)`

**Impact**:

- Foreign key references in comment_reactions table will fail
- Reaction functionality will break

**TypeScript Definition**:

```typescript
export interface Reaction {
  id: string; // Should be UUID but SQL uses VARCHAR(50)
  emoji: string;
  name: string;
}
```

**SQL Definition**:

```sql
CREATE TABLE IF NOT EXISTS reactions (
    id VARCHAR(50) PRIMARY KEY, -- Should be UUID to match other tables
    emoji VARCHAR(10) NOT NULL,
    name VARCHAR(100) NOT NULL UNIQUE
);
```

**Fix Required**: Change SQL to use UUID:

```sql
CREATE TABLE IF NOT EXISTS reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    emoji VARCHAR(10) NOT NULL,
    name VARCHAR(100) NOT NULL UNIQUE
);
```

---

### 5. Issue Label ID Type Mismatch

**Location**:

- TypeScript: `types/entities/issueLabel.ts`
- SQL: `db/schema/008_create_issue_labels.sql`

**Issue**:

- TypeScript expects `IssueLabel.id` to be a UUID (string)
- SQL defines `issue_labels.id` as `VARCHAR(50)`

**Impact**:

- Foreign key references in issue_label_relations table will fail
- Label functionality will break

**TypeScript Definition**:

```typescript
export interface IssueLabel {
  id: string; // Should be UUID but SQL uses VARCHAR(50)
  workspaceId: string;
  teamId?: string;
  name: string;
  color: string;
  description?: string;
}
```

**SQL Definition**:

```sql
CREATE TABLE IF NOT EXISTS issue_labels (
    id VARCHAR(50) PRIMARY KEY, -- Should be UUID to match other tables
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    color VARCHAR(7) NOT NULL CHECK (color ~ '^#[0-9A-Fa-f]{6}$'),
    description TEXT,
    CONSTRAINT unique_label_name_per_workspace UNIQUE (workspace_id, name)
);
```

**Fix Required**: Change SQL to use UUID:

```sql
CREATE TABLE IF NOT EXISTS issue_labels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- ... other fields remain the same
);
```

---

### 6. Link ID Type Mismatch

**Location**:

- TypeScript: `types/entities/link.ts`
- SQL: `db/schema/017_create_links.sql`

**Issue**:

- TypeScript expects `Link.id` to be a UUID (string)
- SQL defines `links.id` as `VARCHAR(50)`

**Impact**:

- Link functionality will break
- Foreign key relationships may fail

**TypeScript Definition**:

```typescript
export interface Link {
  id: string; // Should be UUID but SQL uses VARCHAR(50)
  workspaceId: string;
  issueId: string;
  title: string;
  url: string;
  createdAt: Date;
  updatedAt: Date;
}
```

**SQL Definition**:

```sql
CREATE TABLE IF NOT EXISTS links (
    id VARCHAR(50) PRIMARY KEY, -- Should be UUID to match other tables
    workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    url TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

**Fix Required**: Change SQL to use UUID:

```sql
CREATE TABLE IF NOT EXISTS links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- ... other fields remain the same
);
```

---

## ✅ Consistent Areas

The following areas are correctly aligned between TypeScript and SQL:

1. **Workspace, Team, Project, Issue, Milestone** - All use UUID for IDs
2. **Enum values** - All match between TypeScript and SQL constraints:
   - Priority: `'no-priority' | 'urgent' | 'high' | 'medium' | 'low'`
   - Status: `'backlog' | 'todo' | 'in-progress' | 'done' | 'canceled' | 'duplicate'`
   - ProjectStatus: `'planned' | 'started' | 'paused' | 'completed' | 'canceled'`
   - TeamRole: `'lead' | 'member' | 'viewer'`
   - WorkspaceRole: `'owner' | 'admin' | 'member' | 'guest'`
3. **Foreign key relationships** - All properly defined
4. **Timestamps** - All use `created_at`/`updated_at` pattern
5. **Membership tables** - Properly structured with correct roles
6. **Junction tables** - All many-to-many relationships are correctly implemented

---

## 🔧 Recommended Fix Strategy

### Priority Order:

1. **HIGH**: Fix User ID type mismatch (affects all foreign key references)
2. **HIGH**: Fix Comment ID type mismatch (affects issue relationships)
3. **MEDIUM**: Fix Reaction, IssueLabel, and Link ID types
4. **MEDIUM**: Add missing User roles column

### Implementation Approach:

1. **Option 1 (Recommended)**: Update SQL Schema

   - Change all VARCHAR(50) ID columns to UUID
   - Add missing roles column to users table
   - This maintains consistency with the UUID pattern used elsewhere

2. **Option 2**: Update TypeScript Types

   - Change ID types to match VARCHAR(50) in SQL
   - This would be inconsistent with the UUID pattern used elsewhere

3. **Option 3**: Mixed Approach
   - Keep UUID for new tables
   - Update specific tables to use VARCHAR(50) if needed for external integrations

---

## 🎯 Impact Assessment

### Database Operations That Will Fail:

- Foreign key constraint violations
- Type casting errors when UUIDs are passed to VARCHAR columns
- Application crashes when trying to access missing columns

### Affected Features:

- User authentication and role management
- Comment threading and relationships
- Issue labeling system
- Reaction system
- Link management
- All membership and subscription features

---

## 📝 Migration Notes

When fixing these inconsistencies:

1. **Backup the database** before making schema changes
2. **Update all foreign key references** to match the new ID types
3. **Update any application code** that assumes specific ID formats
4. **Test thoroughly** after each change
5. **Consider data migration** if existing data needs to be converted

---

## 🔍 Files to Update

### SQL Schema Files:

- `db/schema/002_create_users.sql`
- `db/schema/007_create_comments.sql`
- `db/schema/008_create_issue_labels.sql`
- `db/schema/009_create_reactions.sql`
- `db/schema/017_create_links.sql`

### TypeScript Files (if choosing Option 2):

- `types/entities/user.ts`
- `types/entities/comment.ts`
- `types/entities/reaction.ts`
- `types/entities/issueLabel.ts`
- `types/entities/link.ts`

---

_Last updated: [Current Date]_
_Status: Critical - Requires immediate attention_
