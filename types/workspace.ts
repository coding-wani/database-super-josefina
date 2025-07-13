export interface Workspace {
  id: string; // UUID (internal)
  publicId: string; // User-facing ID (e.g., "IW" for "interesting-workspace")
  name: string;
  icon?: string; // Emoji or image URL
  description?: string;
  createdAt: Date;
  updatedAt: Date;
}
