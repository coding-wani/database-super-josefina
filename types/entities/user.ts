export interface User {
  id: string; // VARCHAR(50) - Kept for OAuth provider compatibility (Not UUID)
  username: string;
  email?: string;
  avatar?: string; // Optional - user might not have uploaded an avatar yet
  firstName?: string;
  lastName?: string;
  isOnline: boolean; // Required - always has a value (default: false)
  currentWorkspaceId?: string; // Last active workspace
  
  /**
   * Array of current role names for quick access (e.g., ["super_admin", "beta_tester"])
   * 
   * Note: This field contains only the user's CURRENT active roles for quick permission checks.
   * For the complete history of role assignments, removals, and expirations, see the
   * user_role_assignment_events table which maintains a full audit trail.
   */
  roles: string[];
  
  createdAt: Date;
  updatedAt: Date;
}