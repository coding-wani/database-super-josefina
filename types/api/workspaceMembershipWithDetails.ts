import { WorkspaceMembership } from "../workspaceMembership";
import { Workspace } from "../workspace";
import { User } from "../user";

// ===== API RESPONSE TYPE (Composed from DB models) =====
// These are NOT stored in the database, they're just TypeScript types
// for API responses that JOIN data together

export interface WorkspaceMembershipWithDetails {
  membership: WorkspaceMembership;
  workspace: Workspace;
  invitedByUser?: User;
}
