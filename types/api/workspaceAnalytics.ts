// =====================================================
// types/api/workspaceAnalytics.ts
// PURPOSE: API response type for workspace analytics(NB:1)
// SOURCE TABLES: Multiple tables aggregated for metrics
// 
// KEY CONCEPTS:
// - Comprehensive workspace performance metrics
// - Time-series data for trend analysis
// - Team, user, and project breakdowns
// - Used for admin dashboards and reporting
//
// NB:
// (1) API RESPONSE TYPE (Aggregated Data)
// This type contains computed analytics from multiple
// database tables for workspace performance insights
// =====================================================

export interface WorkspaceAnalytics {
  // ===== ANALYTICS SCOPE =====
  workspaceId: string;         // Workspace being analyzed
  period: {                    // Time period for analytics
    start: Date;               // Analysis start date
    end: Date;                 // Analysis end date
  };
  
  // ===== TEAM PERFORMANCE =====
  teamStats: Array<{
    teamId: string;            // Team identifier
    teamName: string;          // Team display name
    issueCount: number;        // Total issues for team
    completionRate: number;    // Percentage of completed issues
    avgResolutionTime: number; // Average time to resolve (hours)
    activeMembers: number;     // Active team members in period
  }>;
  
  // ===== USER ACTIVITY =====
  userStats: Array<{
    userId: string;            // User identifier
    username: string;          // User display name
    avatar?: string;           // User profile image
    issuesCreated: number;     // Issues created by user
    issuesResolved: number;    // Issues resolved by user
    issuesAssigned: number;    // Issues assigned to user
    commentsAdded: number;     // Comments made by user
    lastActiveAt: Date;        // Last activity timestamp
  }>;
  
  // ===== PROJECT PROGRESS =====
  projectStats: Array<{
    projectId: string;         // Project identifier
    projectName: string;       // Project display name
    status: string;            // Current project status
    progress: number;          // Completion percentage
    issueCount: number;        // Total issues in project
    overdueCount: number;      // Overdue issues count
  }>;
  
  // ===== TREND DATA =====
  trends: {
    issueVelocity: number[];   // Issues created per day
    resolutionRate: number[];  // Issues resolved per day
    activeUsers: number[];     // Active users per day
  };
  
  // ===== LABEL USAGE =====
  topLabels: Array<{
    labelId: string;           // Label identifier
    name: string;              // Label display name
    color: string;             // Label color code
    count: number;             // Usage frequency
  }>;
  
  // ===== SUMMARY METRICS =====
  summary: {
    totalIssues: number;       // All issues in workspace
    openIssues: number;        // Currently open issues
    resolvedIssues: number;    // Completed issues
    totalUsers: number;        // All workspace users
    activeUsers: number;       // Users active in period
    totalProjects: number;     // All workspace projects
    activeProjects: number;    // Projects with activity
    avgResolutionTime: number; // Average resolution time (hours)
  };
}
