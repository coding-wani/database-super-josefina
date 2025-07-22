export interface User {
  id: string; // VARCHAR(50) - Kept for OAuth provider compatibility (Not UUID)
  username: string;
  email?: string;
  avatar?: string; // Optional - user might not have uploaded an avatar yet
  firstName?: string;
  lastName?: string;
  isOnline: boolean; // Required - always has a value (default: false)
  currentWorkspaceId?: string; // Last active workspace
  roles: string[]; // Current roles - simple array of role names (e.g., ["super_admin", "beta_tester"])
  createdAt: Date;
  updatedAt: Date;
}