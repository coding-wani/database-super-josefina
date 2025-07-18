import { User } from "../entities/user";
import { UserRole } from "../entities/userRole";

// ===== API RESPONSE TYPE (Composed from DB models) =====
// This type represents a user with their complete role information
// Used when you need to show user permissions and role details

export interface UserRoleAssignmentDetails {
  roleId: string;
  role: UserRole; // Full role details including permissions
  workspaceId?: string;
  assignedBy?: string;
  assignedByUser?: User; // Full details of who assigned the role
  assignedAt: Date;
  expiresAt?: Date;
}

export interface UserWithRoles {
  user: User;
  roleAssignments: UserRoleAssignmentDetails[];
}
