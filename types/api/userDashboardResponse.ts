import { User } from "../user";
import { WorkspaceMembership } from "../workspaceMembership";
import { Workspace } from "../workspace";
import { TeamMembership } from "../teamMembership";
import { Team } from "../team";

// ===== API RESPONSE TYPE (Composed from DB models) =====
// These are NOT stored in the database, they're just TypeScript types
// for API responses that JOIN data together

export interface UserDashboardResponse {
  user: User;
  workspaces: Array<{
    membership: WorkspaceMembership;
    workspace: Workspace;
  }>;
  teams: Array<{
    membership: TeamMembership;
    team: Team;
  }>;
}
