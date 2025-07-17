export interface User {
  id: string; // VARCHAR(50) - Kept for OAuth provider compatibility (Not UUID)
  username: string;
  email?: string;
  avatar: string;
  firstName?: string;
  lastName?: string;
  isOnline?: boolean;
  currentWorkspaceId?: string; // Last active workspace
  roles?: string[]; // Simple array of role names (e.g., ["super_admin", "beta_tester"])
  createdAt: Date;
  updatedAt: Date;
}
