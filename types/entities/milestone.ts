export interface Milestone {
  id: string; // UUID (internal)
  publicId: string; // User-facing ID (e.g., "MILE-01")
  projectId: string; // Foreign key to Project (required - milestone belongs to project)
  title: string;
  description?: string; // Markdown content
  icon?: string; // Emoji or image URL

  /**
   * The following fields are computed from the database view `milestone_stats`
   * and are not stored directly in the milestones table. They are populated
   * when querying milestones with their statistics.
   */
  
  // Total number of issues in this milestone (computed from milestone_stats view)
  totalIssues?: number;
  
  // Issue count breakdown by status (computed from milestone_stats view)
  issuesByStatus?: {
    triage: number;
    backlog: number;
    todo: number;
    planning: number;
    "in-progress": number;
    "in-review": number;
    done: number;
    commit: number;
    canceled: number;
    decline: number;
    duplicate: number;
  };
  
  // Progress percentage: (done + commit) / total * 100 (computed from milestone_stats view)
  progressPercentage?: number;

  createdAt: Date;
  updatedAt: Date;
}