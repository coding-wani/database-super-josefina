# SQL Files Complexity Analysis

This document analyzes complex SQL features and provides implementation guidance for kept features.

## 🟢 KEPT FEATURES (Implementation Required)

### 1. **Row Level Security (RLS) - `022_enable_rls.sql`** ✅ KEEPING
**Complexity Level**: HIGH but VALUABLE for security
**What it does**: Automatically filters data based on user permissions - prevents data leaks between workspaces

**Security benefits**:
- Prevents accidental cross-workspace data access
- Protects against SQL injection attacks  
- Ensures users only see their workspace data even if app code has bugs

**IMPLEMENTATION REQUIRED**: Your application must set the current user before each database operation:

#### Required Setup in Your App:

```javascript
// Method 1: Set user for each request (recommended)
async function executeQuery(query, params, currentUserId) {
  // Set the current user for RLS
  await db.query("SET app.current_user = $1", [currentUserId]);
  
  // Now execute your actual query - RLS will automatically filter results
  return await db.query(query, params);
}

// Method 2: Set user at connection level
async function setupUserConnection(userId) {
  await db.query("SET app.current_user = $1", [userId]);
}

// Method 3: Using connection pooling with user context
class DatabaseService {
  async withUser(userId, callback) {
    const connection = await this.pool.connect();
    try {
      await connection.query("SET app.current_user = $1", [userId]);
      return await callback(connection);
    } finally {
      connection.release();
    }
  }
}
```

#### Example Usage:
```javascript
// Before RLS setup - queries could accidentally return wrong data
const issues = await db.query('SELECT * FROM issues WHERE assignee_id = $1', [userId]);

// After RLS setup - safe even without workspace filter
await db.query("SET app.current_user = $1", [currentUserId]);
const issues = await db.query('SELECT * FROM issues WHERE assignee_id = $1', [userId]);
// RLS automatically adds: AND workspace_id IN (user's workspaces)
```

#### Debugging RLS:
```sql
-- Check current user setting
SELECT current_setting('app.current_user', true);

-- Test policy manually
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM issues WHERE assignee_id = 'user123';

-- Disable RLS temporarily for debugging (as superuser)
ALTER TABLE issues DISABLE ROW LEVEL SECURITY;
-- Remember to re-enable: ALTER TABLE issues ENABLE ROW LEVEL SECURITY;
```

### 2. **User Roles System - `001_create_user_roles.sql` + `024_create_user_role_assignments.sql`** ✅ KEEPING
**Complexity Level**: HIGH but POWERFUL for permissions
**What it does**: Advanced permission system with JSONB permissions and workspace-specific roles

**Key Features**:
- JSONB permissions for granular control: `["issues.create", "projects.delete", "api.*"]`
- Workspace-specific roles (different permissions per workspace)
- System roles vs custom roles
- Role expiration support
- Permission inheritance

#### Implementation Examples:

```javascript
// Check user permissions
async function hasPermission(userId, permission, workspaceId = null) {
  const query = `
    SELECT EXISTS(
      SELECT 1 FROM user_role_assignments ura
      JOIN user_roles ur ON ura.role_id = ur.id
      WHERE ura.user_id = $1 
        AND (ura.workspace_id = $2 OR ura.workspace_id IS NULL)
        AND (ura.expires_at IS NULL OR ura.expires_at > NOW())
        AND ur.is_active = true
        AND (ur.permissions ? $3 OR ur.permissions ? '*')
    )
  `;
  const result = await db.query(query, [userId, workspaceId, permission]);
  return result.rows[0].exists;
}

// Assign role to user
async function assignRole(userId, roleId, workspaceId, assignedBy) {
  await db.query(`
    INSERT INTO user_role_assignments (user_id, role_id, workspace_id, assigned_by)
    VALUES ($1, $2, $3, $4)
  `, [userId, roleId, workspaceId, assignedBy]);
}

// Create custom workspace role
async function createWorkspaceRole(workspaceId, name, permissions) {
  await db.query(`
    INSERT INTO user_roles (name, display_name, permissions, workspace_id)
    VALUES ($1, $2, $3, $4)
  `, [name, name.replace('_', ' '), JSON.stringify(permissions), workspaceId]);
}
```

### 3. **Bidirectional Issue Relations - `019_create_issue_related_issues.sql`** ✅ KEEPING
**Complexity Level**: MEDIUM but GREAT UX
**What it does**: Automatically maintains two-way relationships between issues

**Benefits**:
- When Issue A relates to Issue B, Issue B automatically shows Issue A as related
- Intuitive user experience - relationships work both ways
- Simplified queries - no need to check both directions

#### Usage:
```javascript
// Add relationship (automatically creates reverse)
await db.query(`
  INSERT INTO issue_related_issues (issue_id, related_issue_id)
  VALUES ($1, $2)
`, [issueA, issueB]);

// Query related issues (simple - bidirectional trigger handles complexity)
const related = await db.query(`
  SELECT ri.*, i.title, i.status 
  FROM issue_related_issues ri
  JOIN issues i ON ri.related_issue_id = i.id
  WHERE ri.issue_id = $1
`, [issueId]);
```

## 🟡 MODERATELY COMPLEX (Kept - No Action Needed)

### 4. **Milestone Stats View - `023_create_milestone_stats_view.sql`** ✅ KEEPING
**What it does**: Pre-calculated statistics for milestones
**Usage**: `SELECT * FROM milestone_stats WHERE milestone_id = $1`

### 5. **Automatic Updated_at Triggers - Multiple files** ✅ KEEPING
**What it does**: Automatically updates `updated_at` timestamp on every UPDATE
**No implementation needed**: Works automatically

### 6. **Complex Constraints and Checks - Multiple files** ✅ KEEPING
**What it does**: Database-level validation (color hex codes, business rules)
**No implementation needed**: Prevents invalid data automatically

## 🔴 REMOVED FEATURES

### ❌ **Audit Log with Triggers** - REMOVED
**Files deleted**: 
- `db/schema/025_create_audit_log.sql`
- `types/entities/auditLog.ts`
- Reference removed from `db/setup.sql`

**Reason**: Complex feature that can be added later if needed for compliance

## 🟢 SIMPLE FEATURES (No Issues)

- Basic tables and relationships
- Junction tables for many-to-many relationships  
- Basic indexes for performance
- Simple data seeding

## Implementation Priority

1. **CRITICAL**: Set up RLS user context in your app (security requirement)
2. **HIGH**: Implement user permission checking system
3. **MEDIUM**: Use bidirectional relations in your issue UI
4. **LOW**: Use milestone stats view for dashboard metrics

## Summary

**Kept all valuable features** except audit logging. Your database now provides:
- ✅ Strong security with RLS
- ✅ Advanced permission system
- ✅ Intuitive issue relationships
- ✅ Performance optimizations
- ✅ Data integrity constraints

**Next step**: Implement RLS user context in your application for security.