
// =====================================================
// types/relationships/workspaceMembership.ts
// PURPOSE: Links users to workspaces with roles(NB:1)
// DATABASE TABLE: workspace_memberships
// 
// KEY CONCEPTS:
// - Foundation of multi-tenancy (RLS uses this)
// - User can be in multiple workspaces
// - Different role per workspace
// - Tracks who invited whom
//
// NB:
// (1) RELATIONSHIP TYPE (Junction Table)
// This type represents a many-to-many relationship
// between users and workspaces with additional metadata
// =====================================================

import { WorkspaceRole } from "../enums/workspaceRole";

export interface WorkspaceMembership {
  // ===== PRIMARY KEY =====
  id: string;              // UUID
  
  // ===== FOREIGN KEYS =====
  userId: string;          // User in workspace (VARCHAR(50))
  workspaceId: string;     // Workspace they belong to (UUID)
  
  // ===== MEMBERSHIP DATA =====
  role: WorkspaceRole;     // owner, admin, member, or guest
  joinedAt: Date;          // When they joined
  invitedBy?: string;      // User who invited them (VARCHAR(50))
                          // NULL for original owner
}