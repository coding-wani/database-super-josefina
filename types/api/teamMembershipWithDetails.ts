// =====================================================
// types/api/teamMembershipWithDetails.ts
// PURPOSE: API response type for team membership details(NB:1)
// SOURCE TABLES: team_memberships + teams
// 
// KEY CONCEPTS:
// - Combines membership data with team details
// - Used for user's team list views
// - Avoids separate API calls for team info
// - Displays role within team context
//
// NB:
// (1) API RESPONSE TYPE (Composed Data)
// This type joins team membership relationships
// with full team details for display purposes
// =====================================================

import { Team } from "../entities/team";
import { TeamMembership } from "../relationships/teamMembership";

export interface TeamMembershipWithDetails {
  // ===== MEMBERSHIP DATA =====
  membership: TeamMembership;  // User's role and join date
  
  // ===== TEAM CONTEXT =====
  team: Team;                  // Full team information
}
