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
  roles?: string[]; // Legacy - Simple array of role names (for backward compatibility)
  roleAssignments?: UserRoleAssignment[]; // New role system with full audit trail (populated via joins)
  createdAt: Date;
  updatedAt: Date;
}
