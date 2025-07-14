export interface User {
  id: string;
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
