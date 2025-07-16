import { Project } from "../entities/project";
import { User } from "../entities/user";
import { Team } from "../entities/team";
import { Milestone } from "../entities/milestone";
import { Status } from "../enums/status";
import { Priority } from "../enums/priority";

// ===== API RESPONSE TYPE (Composed from DB models) =====
// This type represents a complete project overview with statistics
// Used for project dashboards and summary views

export interface ProjectOverview {
  project: Project;
  lead?: User;
  team?: Team;
  milestones: Milestone[];
  members: Array<{
    user: User;
    role: string;
  }>;
  issueStats: {
    total: number;
    byStatus: Record<Status, number>;
    byPriority: Record<Priority, number>;
    overdue: number;
    completionRate: number;
  };
  recentActivity: Array<{
    type:
      | "issue_created"
      | "issue_updated"
      | "comment_added"
      | "milestone_completed";
    timestamp: Date;
    userId: string;
    details: any;
  }>;
}
