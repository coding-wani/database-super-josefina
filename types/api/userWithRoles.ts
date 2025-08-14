// =====================================================
// types/api/userWithRoles.ts
// PURPOSE: API response type for user with role details(NB:1)
// SOURCE TABLES: users + user_roles + user_role_assignments
// 
// KEY CONCEPTS:
// - User data with complete role information
// - Role assignments with context (workspace, expiry)
// - Permission details for access control
// - Audit trail of who assigned roles
//
// NB:
// (1) API RESPONSE TYPE (Composed Data)
// This type combines user data with detailed role
// assignments for permission management and display
// =====================================================

import { User } from "../entities/user";
import { UserRole } from "../entities/userRole";

export interface UserRoleAssignmentDetails {
  // ===== ROLE ASSIGNMENT DATA =====
  roleId: string;              // Role being assigned
  role: UserRole;              // Full role details with permissions
  
  // ===== ASSIGNMENT CONTEXT =====
  workspaceId?: string;        // Workspace scope (if applicable)
  assignedBy?: string;         // User ID who assigned role
  assignedByUser?: User;       // Full details of assigner
  
  // ===== ASSIGNMENT TIMELINE =====
  assignedAt: Date;            // When role was assigned
  expiresAt?: Date;            // When assignment expires (optional)
}

export interface UserWithRoles {
  // ===== USER DATA =====
  user: User;                  // Base user information
  
  // ===== ROLE INFORMATION =====
  roleAssignments: UserRoleAssignmentDetails[];  // All role assignments
}
