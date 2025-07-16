import { User } from "../entities/user";
import { WorkspaceMembership } from "../relationships/workspaceMembership";
import { Workspace } from "../entities/workspace";
import { TeamMembership } from "../relationships/teamMembership";
import { Team } from "../entities/team";

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
