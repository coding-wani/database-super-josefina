// =====================================================
// types/entities/userRole.ts
// PURPOSE: Permission roles for access control
// DATABASE TABLE: user_roles
// 
// SCOPE:
// - Global roles: workspaceId = NULL (system-wide)
// - Workspace roles: workspaceId set (workspace-specific)
// 
// SYSTEM ROLES:
// - super_admin: Full system access
// - beta_tester: Beta features
// - developer: API access
// - support_staff: Support tools
// =====================================================

export interface UserRole {
  // ===== IDENTIFIERS =====
  id: string;              // UUID (internal)
  publicId: string;        // User-facing (e.g., "ROLE-SUPER-ADMIN")
  
  // ===== ROLE DEFINITION =====
  name: string;            // System name (e.g., "super_admin")
  displayName: string;     // UI name (e.g., "Super Administrator")
  description?: string;    // Role explanation
  
  // ===== PERMISSIONS =====
  // Dot notation for hierarchical permissions
  // Examples:
  // - "*" = everything
  // - "projects.*" = all project permissions
  // - "issues.create" = can create issues
  // - "api.read" = read-only API access
  permissions: string[];
  
  // ===== SCOPE =====
  workspaceId?: string;    // NULL for global roles
  
  // ===== FLAGS =====
  isSystem: boolean;       // System roles can't be deleted
  isActive: boolean;       // Can be disabled without deletion
  
  // ===== TIMESTAMPS =====
  createdAt: Date;
  updatedAt: Date;
}