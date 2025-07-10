export interface User {
  id: string;
  username: string;
  email?: string;
  avatar: string;
  firstName?: string;
  lastName?: string;
  isOnline?: boolean;
  roles?: string[];
  createdAt: Date;
  updatedAt: Date;
}
