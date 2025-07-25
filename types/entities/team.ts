import { EstimationType } from "../enums/estimationType";

export interface Team {
  id: string; // UUID (internal)
  publicId: string; // User-facing ID (e.g., "SM" for "School Manager")
  workspaceId: string; // Foreign key to Workspace
  name: string;
  icon?: string; // Emoji or image URL
  description?: string;
  withEstimation: boolean; // Default: false
  estimationType?: EstimationType; // Only set when withEstimation is true
  createdAt: Date;
  updatedAt: Date;
}