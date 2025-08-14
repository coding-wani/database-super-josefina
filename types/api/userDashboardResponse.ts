// =====================================================
// types/api/userDashboardResponse.ts
// PURPOSE: API response type for user dashboard(NB:1)
// SOURCE TABLES: users + workspace_memberships + workspaces + team_memberships + teams
// 
// KEY CONCEPTS:
// - Complete user context with memberships
// - Used for main dashboard after login
// - Shows all workspaces and teams user belongs to
// - Includes role information for each membership
//
// NB:
// (1) API RESPONSE TYPE (Composed Data)
// This type aggregates user data with all their
// organizational memberships for dashboard display
// =====================================================

import { User } from "../entities/user";
import { WorkspaceMembership } from "../relationships/workspaceMembership";
import { Workspace } from "../entities/workspace";
import { TeamMembership } from "../relationships/teamMembership";
import { Team } from "../entities/team";

export interface UserDashboardResponse {
  // ===== USER DATA =====
  user: User;                  // Current user information
  
  // ===== WORKSPACE MEMBERSHIPS =====
  workspaces: Array<{
    membership: WorkspaceMembership;  // User's role in workspace
    workspace: Workspace;             // Workspace details
  }>;
  
  // ===== TEAM MEMBERSHIPS =====
  teams: Array<{
    membership: TeamMembership;       // User's role in team
    team: Team;                       // Team details
  }>;
}
