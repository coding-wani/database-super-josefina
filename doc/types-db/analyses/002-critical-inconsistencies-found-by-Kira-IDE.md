# Critical Inconsistencies Found Between Database Schema and TypeScript Types

## 1. **User ID Type Mismatch**
- **Database**: `users.current_workspace_id` is `UUID` type
- **TypeScript**: `User.currentWorkspaceId` is `string` type
- **Issue**: While both are strings at runtime, the TypeScript type should specify it's a UUID string for clarity
- **Impact**: Type safety and documentation clarity

## 2. **Missing Database Tables for TypeScript Entities**
Several TypeScript interfaces reference data that doesn't have corresponding database tables:

### 2.1 User Role Assignments
- **TypeScript**: `User.roles` is `string[]` (array of role names)
- **Database**: Has `user_role_assignments` table but `users.roles` is `TEXT[]`
- **Issue**: Inconsistent role storage - should use either the junction table OR the array field, not both
- **Recommendation**: Use `user_role_assignments` table and remove `roles` field from `users` table

## 3. **ID Type Inconsistencies**
Several entities have inconsistent ID types between database and TypeScript:

### 3.1 Comments
- **Database**: `comments.id` is `UUID`
- **TypeScript**: `Comment.id` is `string`
- **Note**: This is acceptable but should be documented as UUID string

### 3.2 Issue Labels
- **Database**: `issue_labels.id` is `UUID`
- **TypeScript**: `IssueLabel.id` is `string`
- **Note**: This is acceptable but should be documented as UUID string

## 4. **Missing Foreign Key Constraints**
### 4.1 User Roles Reference
- **Database**: `user_roles` table references `workspaces(id)` but this creates a circular dependency since `workspaces` is created before `user_roles`
- **Issue**: Schema file `001_create_user_roles.sql` references `workspaces(id)` but workspaces are created in `002_create_workspaces.sql`
- **Fix**: Move user_roles creation after workspaces or remove the foreign key constraint initially

## 5. **Enum Value Mismatches**
All enum values appear to be consistent between database CHECK constraints and TypeScript enums. ✅

## 6. **Missing Database Fields**
### 6.1 Issue Labels Color Validation
- **Database**: `issue_labels.color` has regex validation `^#[0-9A-Fa-f]{6}$` but the regex appears incomplete
- **Issue**: The CHECK constraint in `009_create_issue_labels.sql` seems to be cut off
- **Fix**: Complete the color validation regex

## 7. **Inconsistent Naming Conventions**
### 7.1 Snake Case vs Camel Case
- **Database**: Uses `snake_case` (e.g., `created_at`, `updated_at`)
- **TypeScript**: Uses `camelCase` (e.g., `createdAt`, `updatedAt`)
- **Note**: This is expected and handled by ORM mapping, but should be documented

## 8. **Missing Indexes for Performance**
While there are comprehensive indexes in `016_create_indexes.sql`, some commonly queried fields might benefit from additional indexes:
- `users.current_workspace_id` - frequently used for user context
- `user_role_assignments.expires_at` - for cleaning up expired roles

## 9. **RLS Policy Gaps**
### 9.1 Missing RLS Policies
The following tables have RLS enabled but no policies defined:
- `comments` - needs access policy
- `issue_labels` - needs access policy  
- `reactions` - needs access policy
- `links` - needs access policy
- All junction tables (subscriptions, favorites, etc.)

## 10. **Data Validation Issues**
### 10.1 User Roles Permissions
- **Database**: `user_roles.permissions` is `JSONB` storing array of strings
- **TypeScript**: `UserRole.permissions` is `string[]`
- **Issue**: No validation that JSONB actually contains string array
- **Fix**: Add CHECK constraint to validate JSONB structure

## Summary
The most critical issues are:
1. **Circular dependency** in user_roles table creation
2. **Incomplete color validation** regex in issue_labels
3. **Missing RLS policies** for several tables
4. **Inconsistent role management** between array field and junction table

These issues should be addressed to ensure data integrity and proper security implementation.