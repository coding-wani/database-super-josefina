import { Team } from "../team";
import { TeamMembership } from "../teamMembership";

// ===== API RESPONSE TYPE (Composed from DB models) =====
// These are NOT stored in the database, they're just TypeScript types
// for API responses that JOIN data together

export interface TeamMembershipWithDetails {
  membership: TeamMembership;
  team: Team;
}
