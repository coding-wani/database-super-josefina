import { UserRoleAssignment } from "./userRoleAssignment";

export interface User {
  id: string; // VARCHAR(50) - Kept for OAuth provider compatibility (Not UUID)
  username: string;
  email?: string;
  avatar: string;
  firstName?: string;
  lastName?: string;
  isOnline?: boolean;
  currentWorkspaceId?: string; // Last active workspace
  // todo : remove the roles array and use the roleAssignments array instead ?
  roles?: string[]; // Legacy - Array of role names (consider deprecating)
  roleAssignments?: UserRoleAssignment[]; // New role system (populated via joins)
  createdAt: Date;
  updatedAt: Date;
}
