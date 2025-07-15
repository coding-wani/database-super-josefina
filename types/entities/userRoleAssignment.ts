export interface UserRoleAssignment {
  id: string; // UUID
  userId: string; // VARCHAR(50) - OAuth compatible
  roleId: string; // UUID - references user_roles
  workspaceId?: string; // UUID - for workspace-specific assignments
  assignedBy?: string; // VARCHAR(50) - references users
  assignedAt: Date;
  expiresAt?: Date; // Optional expiration
}
