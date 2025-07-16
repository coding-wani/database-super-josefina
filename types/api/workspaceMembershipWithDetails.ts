import { WorkspaceMembership } from "../relationships/workspaceMembership";
import { Workspace } from "../entities/workspace";
import { User } from "../entities/user";

// ===== API RESPONSE TYPE (Composed from DB models) =====
// These are NOT stored in the database, they're just TypeScript types
// for API responses that JOIN data together

export interface WorkspaceMembershipWithDetails {
  membership: WorkspaceMembership;
  workspace: Workspace;
  invitedByUser?: User;
}
