// =====================================================
// types/api/workspaceMembershipWithDetails.ts
// PURPOSE: API response type for workspace membership details(NB:1)
// SOURCE TABLES: workspace_memberships + workspaces + users
// 
// KEY CONCEPTS:
// - Combines membership data with workspace details
// - Used for user's workspace list views
// - Includes invitation context information
// - Avoids separate API calls for workspace info
//
// NB:
// (1) API RESPONSE TYPE (Composed Data)
// This type joins workspace membership relationships
// with full workspace and inviter details for display
// =====================================================

import { WorkspaceMembership } from "../relationships/workspaceMembership";
import { Workspace } from "../entities/workspace";
import { User } from "../entities/user";

export interface WorkspaceMembershipWithDetails {
  // ===== MEMBERSHIP DATA =====
  membership: WorkspaceMembership;  // User's role and join date
  
  // ===== WORKSPACE CONTEXT =====
  workspace: Workspace;             // Full workspace information
  
  // ===== INVITATION CONTEXT =====
  invitedByUser?: User;             // Who invited this user (if applicable)
}
