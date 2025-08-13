// =====================================================
// types/enums/workspaceRole.ts
// PURPOSE: User roles within workspaces
// DATABASE: CHECK constraint on workspace_memberships.role
// 
// PERMISSION HIERARCHY (highest to lowest):
// 1. owner: Full control, billing, can delete workspace
// 2. admin: Manage users, settings, integrations
// 3. member: Normal access, create/edit content
// 4. guest: Limited read-only access
// 
// RULES:
// - Must have at least one owner
// - Owners can transfer ownership
// - Only owners/admins can invite users
// =====================================================

export type WorkspaceRole = "owner" | "admin" | "member" | "guest";