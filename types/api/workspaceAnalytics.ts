// ===== API RESPONSE TYPE (Composed from DB models) =====
// This type represents workspace-wide analytics and statistics
// Used for admin dashboards and reporting features

export interface WorkspaceAnalytics {
  workspaceId: string;
  period: {
    start: Date;
    end: Date;
  };
  teamStats: Array<{
    teamId: string;
    teamName: string;
    issueCount: number;
    completionRate: number;
    avgResolutionTime: number; // in hours
    activeMembers: number;
  }>;
  userStats: Array<{
    userId: string;
    username: string;
    avatar?: string;
    issuesCreated: number;
    issuesResolved: number;
    issuesAssigned: number;
    commentsAdded: number;
    lastActiveAt: Date;
  }>;
  projectStats: Array<{
    projectId: string;
    projectName: string;
    status: string;
    progress: number; // percentage
    issueCount: number;
    overdueCount: number;
  }>;
  trends: {
    issueVelocity: number[]; // Issues created per day
    resolutionRate: number[]; // Issues resolved per day
    activeUsers: number[]; // Active users per day
  };
  topLabels: Array<{
    labelId: string;
    name: string;
    color: string;
    count: number;
  }>;
  summary: {
    totalIssues: number;
    openIssues: number;
    resolvedIssues: number;
    totalUsers: number;
    activeUsers: number; // active in period
    totalProjects: number;
    activeProjects: number;
    avgResolutionTime: number; // in hours
  };
}
