import { WorkspaceRole } from "../enums/workspaceRole";

export interface WorkspaceMembership {
  id: string; // UUID
  userId: string; // Foreign key to User
  workspaceId: string; // Foreign key to Workspace
  role: WorkspaceRole;
  joinedAt: Date;
  invitedBy?: string; // Foreign key to User who invited
}
