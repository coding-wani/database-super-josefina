// =====================================================
// types/entities/workspace.ts
// PURPOSE: Top-level multi-tenant container
// DATABASE TABLE: workspaces
// 
// DESCRIPTION:
// Workspaces are the root of data isolation.
// All other entities belong to a workspace.
// RLS policies use workspace membership for access control.
// =====================================================

export interface Workspace {
  // ===== IDENTIFIERS =====
  id: string;              // UUID (internal)
  publicId: string;        // User-facing ID (e.g., "IW" for "interesting-workspace")
                          // Used in URLs: /workspace/IW
  
  // ===== DISPLAY FIELDS =====
  name: string;            // Display name (e.g., "Interesting Workspace")
  icon?: string;           // Emoji (🎯) or image URL
  description?: string;    // Optional workspace description
  
  // ===== TIMESTAMPS =====
  createdAt: Date;
  updatedAt: Date;
}
