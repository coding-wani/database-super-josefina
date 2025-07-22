export interface UserRoleAssignmentEvent {
  id: string; // UUID (internal)
  publicId: string; // User-facing ID like "ROLE-EVT-001" or "ROLE-ASSIGN-2024-001"
  userId: string; // VARCHAR(50) - OAuth compatible
  roleId: string; // UUID - references user_roles
  workspaceId?: string; // UUID - for workspace-specific assignments
  action: "assigned" | "removed" | "expired";
  assignedBy?: string; // VARCHAR(50) - references users (who performed the action)
  createdAt: Date; // When the event occurred
  expiresAt?: Date; // Optional expiration for temporary roles
}
