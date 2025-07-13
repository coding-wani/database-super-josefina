export interface Team {
  id: string; // UUID (internal)
  publicId: string; // User-facing ID (e.g., "SM" for "School Manager")
  workspaceId: string; // Foreign key to Workspace
  name: string;
  icon?: string; // Emoji or image URL
  description?: string;
  createdAt: Date;
  updatedAt: Date;
}
