import { ProjectStatus } from "./projectStatus";
import { Priority } from "./priority";

export interface Project {
  id: string; // UUID (internal)
  publicId: string; // User-facing ID (e.g., "PROJ-01")
  workspaceId: string; // Foreign key to Workspace (always required)
  teamId?: string; // Foreign key to Team (optional - null if workspace-level)
  name: string;
  icon?: string; // Emoji or image URL
  description?: string;
  status: ProjectStatus;
  priority: Priority;
  leadId?: string; // Foreign key to User who leads the project
  startDate?: Date;
  targetDate?: Date;
  createdAt: Date;
  updatedAt: Date;
}
