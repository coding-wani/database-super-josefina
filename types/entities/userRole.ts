export interface UserRole {
  id: string; // UUID (internal)
  publicId: string; // User-facing ID (e.g., "ROLE-SUPER-ADMIN")
  name: string; // System name (e.g., "super_admin")
  displayName: string; // User-friendly name (e.g., "Super Administrator")
  description?: string; // Role description
  permissions: string[]; // Array of permission strings (e.g., ["api.*", "features.beta.*"])
  workspaceId?: string; // Foreign key to Workspace (null for global roles)
  isSystem: boolean; // System roles can't be deleted
  isActive: boolean; // Can be disabled without deletion
  createdAt: Date;
  updatedAt: Date;
}
