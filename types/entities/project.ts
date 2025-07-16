import { ProjectStatus } from "../enums/projectStatus";
import { Priority } from "../enums/priority";
import { Milestone } from "./milestone";

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

  /**
   * Internal counter used to generate the next milestone's publicId (e.g., "PROJ-01-M3").
   * This value does NOT determine milestone execution order.
   */
  nextMilestoneNumber: number;

  // Related data (populated via joins)
  milestones?: Milestone[]; // Array of project milestones

  createdAt: Date;
  updatedAt: Date;
}
