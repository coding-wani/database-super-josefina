export interface Milestone {
  id: string; // UUID (internal)
  publicId: string; // User-facing ID (e.g., "MILE-01")
  projectId: string; // Foreign key to Project (required - milestone belongs to project)
  title: string;
  description?: string; // Markdown content
  icon?: string; // Emoji or image URL

  // Computed fields (from database views or aggregations)
  totalIssues?: number;
  issuesByStatus?: {
    backlog: number;
    todo: number;
    "in-progress": number;
    done: number;
    canceled: number;
    duplicate: number;
  };
  progressPercentage?: number; // Computed from milestone_stats view

  createdAt: Date;
  updatedAt: Date;
}
