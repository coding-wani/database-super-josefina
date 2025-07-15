import { User } from "./user";
import { WorkspaceMembership } from "../relationships/workspaceMembership";
import { TeamMembership } from "../relationships/teamMembership";

// types/userWithMemberships.ts - Extended user model for dashboard/app
export interface UserWithMemberships extends User {
  workspaces: WorkspaceMembership[];
  teams: TeamMembership[];
}
