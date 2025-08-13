// =====================================================
// types/entities/milestone.ts
// PURPOSE: Major checkpoints within projects
// DATABASE TABLE: milestones
// 
// SPECIAL NOTES:
// - Always belongs to a project (never standalone)
// - Progress calculated from issue statuses
// - Statistics come from milestone_stats view
// =====================================================

export interface Milestone {
  // ===== IDENTIFIERS =====
  id: string;              // UUID (internal)
  publicId: string;        // Sequential per project (e.g., "MILE-01")
  
  // ===== RELATIONSHIPS =====
  projectId: string;       // Parent project UUID (required)
  
  // ===== DISPLAY FIELDS =====
  title: string;           // Milestone name
  description?: string;    // Details (Markdown)
  icon?: string;           // Emoji (🎯) or image URL
  
  /**
   * ===== COMPUTED STATISTICS =====
   * The following fields are calculated from the milestone_stats VIEW,
   * not stored in the milestones table. They're populated when querying
   * milestones with JOIN milestone_stats.
   */
  
  // Total issues assigned to this milestone
  totalIssues?: number;
  
  // Issue breakdown by status (from VIEW)
  issuesByStatus?: {
    triage: number;        // New, unprocessed
    backlog: number;       // Accepted, queued
    todo: number;          // Ready to start
    planning: number;      // Being designed
    "in-progress": number; // Active work
    "in-review": number;   // Awaiting review
    done: number;          // Completed
    commit: number;        // Merged/deployed
    canceled: number;      // Won't do
    decline: number;       // Rejected
    duplicate: number;     // Duplicate
  };
  
  // Completion percentage: (done + commit) / total * 100
  progressPercentage?: number;
  
  // ===== TIMESTAMPS =====
  createdAt: Date;
  updatedAt: Date;
}