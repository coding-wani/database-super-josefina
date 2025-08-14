// =====================================================
// types/api/projectOverview.ts
// PURPOSE: API response type for project dashboard(NB:1)
// SOURCE TABLES: projects + users + teams + milestones + issues + activities
// 
// KEY CONCEPTS:
// - Comprehensive project dashboard data
// - Pre-computed statistics and metrics
// - Real-time activity feed
// - Team composition and milestone tracking
//
// NB:
// (1) API RESPONSE TYPE (Composed Data)
// This type aggregates project data with statistics
// for dashboard display and project management
// =====================================================

import { Project } from "../entities/project";
import { User } from "../entities/user";
import { Team } from "../entities/team";
import { Milestone } from "../entities/milestone";
import { Status } from "../enums/status";
import { Priority } from "../enums/priority";

export interface ProjectOverview {
  // ===== CORE PROJECT DATA =====
  project: Project;            // The main project entity
  
  // ===== PROJECT LEADERSHIP =====
  lead?: User;                 // Project lead/manager
  team?: Team;                 // Associated team
  
  // ===== PROJECT STRUCTURE =====
  milestones: Milestone[];     // Project milestones
  members: Array<{             // Project team members
    user: User;                // Team member details
    role: string;              // Their role in project
  }>;
  
  // ===== PROJECT METRICS =====
  issueStats: {
    total: number;                        // Total issues in project
    byStatus: Record<Status, number>;     // Issues grouped by status
    byPriority: Record<Priority, number>; // Issues grouped by priority
    overdue: number;                      // Count of overdue issues
    completionRate: number;               // % of completed issues
  };
  
  // ===== ACTIVITY FEED =====
  recentActivity: Array<{
    type:                        // Activity type
      | "issue_created"
      | "issue_updated"
      | "comment_added"
      | "milestone_completed";
    timestamp: Date;             // When activity occurred
    userId: string;              // User who performed action
    details: {                   // Activity context
      issueId: string;
      issueTitle: string;
      projectName: string;
      assignee: string;
      createdAt: string;
      priority: string;
    };
  }>;
}
