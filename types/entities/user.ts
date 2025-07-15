export interface User {
  id: string; // VARCHAR(50) - Kept for OAuth provider compatibility (Not UUID)
  username: string;
  email?: string;
  avatar: string;
  firstName?: string;
  lastName?: string;
  isOnline?: boolean;
  currentWorkspaceId?: string; // Last active workspace
  roles?: string[]; // Array of user roles (PostgreSQL TEXT[] array)
  createdAt: Date;
  updatedAt: Date;
}
