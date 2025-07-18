export interface UserRoleAssignment {
  id: string; // UUID
  userId: string; // VARCHAR(50) - OAuth compatible
  roleId: string; // UUID - references user_roles
  workspaceId?: string; // UUID - for workspace-specific assignments
  assignedBy?: string; // VARCHAR(50) - references users (who assigned the role)
  assignedAt: Date; // When the role was assigned
  expiresAt?: Date; // Optional expiration for temporary roles
}
