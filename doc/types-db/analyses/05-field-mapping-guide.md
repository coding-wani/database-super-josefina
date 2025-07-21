# Field Mapping Guide: JSON Data ↔ SQL Schema

## Overview
This guide documents the field name mapping between JSON data files (camelCase) and SQL schema (snake_case) to help with data import/export operations.

## Field Mapping Table

| Entity | JSON Field (camelCase) | SQL Column (snake_case) | Type | Notes |
|--------|------------------------|-------------------------|------|-------|
| **All Entities** | `createdAt` | `created_at` | TIMESTAMP | Auto-managed by triggers |
| **All Entities** | `updatedAt` | `updated_at` | TIMESTAMP | Auto-managed by triggers |
| **User** | `firstName` | `first_name` | VARCHAR(100) | Optional |
| **User** | `lastName` | `last_name` | VARCHAR(100) | Optional |
| **User** | `isOnline` | `is_online` | BOOLEAN | Default: false |
| **User** | `currentWorkspaceId` | `current_workspace_id` | UUID | Optional FK |
| **Workspace** | `publicId` | `public_id` | VARCHAR(50) | User-facing ID |
| **Team** | `publicId` | `public_id` | VARCHAR(50) | User-facing ID |
| **Team** | `workspaceId` | `workspace_id` | UUID | FK to workspaces |
| **Project** | `publicId` | `public_id` | VARCHAR(50) | User-facing ID |
| **Project** | `workspaceId` | `workspace_id` | UUID | FK to workspaces |
| **Project** | `teamId` | `team_id` | UUID | Optional FK to teams |
| **Project** | `leadId` | `lead_id` | VARCHAR(50) | Optional FK to users |
| **Project** | `startDate` | `start_date` | DATE | Optional |
| **Project** | `targetDate` | `target_date` | DATE | Optional |
| **Project** | `nextMilestoneNumber` | `next_milestone_number` | INTEGER | Default: 1 |
| **Issue** | `publicId` | `public_id` | VARCHAR(50) | User-facing ID |
| **Issue** | `workspaceId` | `workspace_id` | UUID | FK to workspaces |
| **Issue** | `teamId` | `team_id` | UUID | Optional FK to teams |
| **Issue** | `projectId` | `project_id` | UUID | Optional FK to projects |
| **Issue** | `milestoneId` | `milestone_id` | UUID | Optional FK to milestones |
| **Issue** | `creatorId` | `creator_id` | VARCHAR(50) | FK to users |
| **Issue** | `parentIssueId` | `parent_issue_id` | UUID | Optional FK to issues |
| **Issue** | `parentCommentId` | `parent_comment_id` | UUID | Optional FK to comments |
| **Issue** | `dueDate` | `due_date` | TIMESTAMP | Optional |
| **Issue** | `assigneeId` | `assignee_id` | VARCHAR(50) | Optional FK to users |
| **Comment** | `workspaceId` | `workspace_id` | UUID | FK to workspaces |
| **Comment** | `teamId` | `team_id` | UUID | Optional FK to teams |
| **Comment** | `authorId` | `author_id` | VARCHAR(50) | FK to users |
| **Comment** | `parentIssueId` | `parent_issue_id` | UUID | FK to issues |
| **Comment** | `parentCommentId` | `parent_comment_id` | UUID | Optional FK to comments |
| **Comment** | `threadOpen` | `thread_open` | BOOLEAN | Default: true |
| **Comment** | `commentUrl` | `comment_url` | VARCHAR(500) | Required |
| **Milestone** | `publicId` | `public_id` | VARCHAR(50) | User-facing ID |
| **Milestone** | `projectId` | `project_id` | UUID | FK to projects |
| **IssueLabel** | `workspaceId` | `workspace_id` | UUID | FK to workspaces |
| **IssueLabel** | `teamId` | `team_id` | UUID | Optional FK to teams |
| **Link** | `workspaceId` | `workspace_id` | UUID | FK to workspaces |
| **Link** | `issueId` | `issue_id` | UUID | FK to issues |
| **UserRole** | `publicId` | `public_id` | VARCHAR(50) | User-facing ID |
| **UserRole** | `displayName` | `display_name` | VARCHAR(255) | User-friendly name |
| **UserRole** | `workspaceId` | `workspace_id` | UUID | Optional FK to workspaces |
| **UserRole** | `isSystem` | `is_system` | BOOLEAN | Default: false |
| **UserRole** | `isActive` | `is_active` | BOOLEAN | Default: true |
| **UserRoleAssignment** | `userId` | `user_id` | VARCHAR(50) | FK to users |
| **UserRoleAssignment** | `roleId` | `role_id` | UUID | FK to user_roles |
| **UserRoleAssignment** | `workspaceId` | `workspace_id` | UUID | Optional FK to workspaces |
| **UserRoleAssignment** | `assignedBy` | `assigned_by` | VARCHAR(50) | Optional FK to users |
| **UserRoleAssignment** | `assignedAt` | `assigned_at` | TIMESTAMP | Required |
| **UserRoleAssignment** | `expiresAt` | `expires_at` | TIMESTAMP | Optional |

## Relationship Tables (Junction Tables)

| Table | JSON Field | SQL Column | Type | Notes |
|-------|------------|------------|------|-------|
| **WorkspaceMembership** | `userId` | `user_id` | VARCHAR(50) | FK to users |
| **WorkspaceMembership** | `workspaceId` | `workspace_id` | UUID | FK to workspaces |
| **WorkspaceMembership** | `joinedAt` | `joined_at` | TIMESTAMP | Default: NOW() |
| **WorkspaceMembership** | `invitedBy` | `invited_by` | VARCHAR(50) | Optional FK to users |
| **TeamMembership** | `userId` | `user_id` | VARCHAR(50) | FK to users |
| **TeamMembership** | `teamId` | `team_id` | UUID | FK to teams |
| **TeamMembership** | `joinedAt` | `joined_at` | TIMESTAMP | Default: NOW() |
| **IssueSubscription** | `userId` | `user_id` | VARCHAR(50) | FK to users |
| **IssueSubscription** | `issueId` | `issue_id` | UUID | FK to issues |
| **IssueSubscription** | `subscribedAt` | `subscribed_at` | TIMESTAMP | Default: NOW() |
| **IssueLabelRelation** | `issueId` | `issue_id` | UUID | FK to issues |
| **IssueLabelRelation** | `labelId` | `label_id` | UUID | FK to issue_labels |
| **IssueFavorite** | `userId` | `user_id` | VARCHAR(50) | FK to users |
| **IssueFavorite** | `issueId` | `issue_id` | UUID | FK to issues |
| **IssueFavorite** | `favoritedAt` | `favorited_at` | TIMESTAMP | Default: NOW() |
| **CommentReaction** | `userId` | `user_id` | VARCHAR(50) | FK to users |
| **CommentReaction** | `commentId` | `comment_id` | UUID | FK to comments |
| **CommentReaction** | `reactionId` | `reaction_id` | UUID | FK to reactions |
| **CommentReaction** | `reactedAt` | `reacted_at` | TIMESTAMP | Default: NOW() |
| **CommentSubscription** | `userId` | `user_id` | VARCHAR(50) | FK to users |
| **CommentSubscription** | `commentId` | `comment_id` | UUID | FK to comments |
| **CommentSubscription** | `subscribedAt` | `subscribed_at` | TIMESTAMP | Default: NOW() |
| **IssueRelatedIssue** | `issueId` | `issue_id` | UUID | FK to issues |
| **IssueRelatedIssue** | `relatedIssueId` | `related_issue_id` | UUID | FK to issues |
| **CommentIssue** | `commentId` | `comment_id` | UUID | FK to comments |
| **CommentIssue** | `issueId` | `issue_id` | UUID | FK to issues |
| **CommentIssue** | `isSubIssue` | `is_sub_issue` | BOOLEAN | Default: false |

## JavaScript/TypeScript Field Mapping Functions

### Convert JSON to SQL (for INSERT operations)
```javascript
function jsonToSql(jsonObj) {
  const sqlObj = {};
  
  for (const [key, value] of Object.entries(jsonObj)) {
    // Convert camelCase to snake_case
    const sqlKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
    sqlObj[sqlKey] = value;
  }
  
  return sqlObj;
}

// Example usage:
const jsonData = { workspaceId: "123", createdAt: "2024-01-01" };
const sqlData = jsonToSql(jsonData);
// Result: { workspace_id: "123", created_at: "2024-01-01" }
```

### Convert SQL to JSON (for SELECT operations)
```javascript
function sqlToJson(sqlObj) {
  const jsonObj = {};
  
  for (const [key, value] of Object.entries(sqlObj)) {
    // Convert snake_case to camelCase
    const jsonKey = key.replace(/_([a-z])/g, (match, letter) => letter.toUpperCase());
    jsonObj[jsonKey] = value;
  }
  
  return jsonObj;
}

// Example usage:
const sqlData = { workspace_id: "123", created_at: "2024-01-01" };
const jsonData = sqlToJson(sqlData);
// Result: { workspaceId: "123", createdAt: "2024-01-01" }
```

## Data Import/Export Considerations

### When Importing JSON Data to SQL:
1. **Field Mapping**: Use the mapping functions above
2. **Date Handling**: Ensure ISO 8601 dates are properly converted to PostgreSQL TIMESTAMP
3. **UUID Validation**: Validate UUID format before insertion
4. **Foreign Key Constraints**: Ensure referenced entities exist before inserting
5. **Null Handling**: Handle `null` vs `undefined` appropriately

### When Exporting SQL Data to JSON:
1. **Field Mapping**: Convert snake_case back to camelCase
2. **Date Serialization**: Convert PostgreSQL timestamps to ISO 8601 strings
3. **Type Conversion**: Ensure proper JavaScript types (boolean, number, string)

## Example Data Import Script

```javascript
// Example: Import issue labels from JSON to SQL
async function importIssueLabels(jsonData) {
  for (const label of jsonData) {
    const sqlData = {
      id: label.id,
      workspace_id: label.workspaceId,
      team_id: label.teamId,
      name: label.name,
      color: label.color,
      description: label.description,
      created_at: new Date(label.createdAt),
      updated_at: new Date(label.updatedAt)
    };
    
    await db.query(`
      INSERT INTO issue_labels (id, workspace_id, team_id, name, color, description, created_at, updated_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      ON CONFLICT (id) DO UPDATE SET
        name = EXCLUDED.name,
        color = EXCLUDED.color,
        description = EXCLUDED.description,
        updated_at = EXCLUDED.updated_at
    `, [
      sqlData.id,
      sqlData.workspace_id,
      sqlData.team_id,
      sqlData.name,
      sqlData.color,
      sqlData.description,
      sqlData.created_at,
      sqlData.updated_at
    ]);
  }
}
```

---

*Field mapping guide created on: 2025-01-22*
*For use with issue tracker database schema*