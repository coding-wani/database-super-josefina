import { User } from "./user";
import { WorkspaceMembership } from "./workspaceMembership";
import { TeamMembership } from "./teamMembership";

// types/userWithMemberships.ts - Extended user model for dashboard/app
export interface UserWithMemberships extends User {
  workspaces: WorkspaceMembership[];
  teams: TeamMembership[];
}
