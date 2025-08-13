// =====================================================
// types/entities/user.ts
// PURPOSE: Core user entity representing authenticated users
// DATABASE TABLE: users
// 
// SPECIAL NOTES:
// - ID is VARCHAR(50) not UUID for OAuth compatibility
// - Supports providers like "google|123456", "github|username"
// - roles array contains current active roles only
// - Full role history in user_role_assignment_events table
// =====================================================

export interface User {
  // ===== PRIMARY KEY =====
  // VARCHAR(50) to support OAuth provider IDs
  // Examples: "user-1", "google|123456789", "auth0|5f7c8ec7"
  id: string;
  
  // ===== AUTHENTICATION FIELDS =====
  username: string;        // Unique display name
  email?: string;          // Optional - some OAuth providers don't provide
  
  // ===== PROFILE FIELDS =====
  avatar?: string;         // URL to profile picture
  firstName?: string;      // Optional personal info
  lastName?: string;       // Optional personal info
  
  // ===== STATUS FIELDS =====
  isOnline: boolean;       // Real-time presence indicator (always has value)
  currentWorkspaceId?: string; // Last active workspace UUID
  
  /**
   * Array of current role names for quick access (e.g., ["super_admin", "beta_tester"])
   * 
   * IMPORTANT: This contains only CURRENT active roles for permission checks.
   * For complete history including past roles, expirations, and who assigned them,
   * query the user_role_assignment_events table.
   * 
   * Common roles:
   * - "super_admin": Full system access
   * - "beta_tester": Access to beta features
   * - "developer": API and dev tools access
   * - "support_staff": Support tools access
   * - Custom workspace-specific roles
   */
  roles: string[];
  
  // ===== TIMESTAMPS =====
  createdAt: Date;         // Account creation
  updatedAt: Date;         // Last profile update
}