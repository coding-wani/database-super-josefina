import { User } from "./user";
import { Reaction } from "./reaction";

export interface Comment {
  id: string; // UUID

  // Multi-tenant fields
  workspaceId: string; // Foreign key to Workspace (for RLS)
  teamId?: string; // Inherited from parent issue's team

  authorId: string; // Foreign key to User.id
  description: string; // The comment content (markdown)
  parentIssueId: string; // Foreign key to Issue.id
  parentCommentId?: string; // Foreign key to Comment.id (for replies)
  threadOpen: boolean;
  commentUrl: string; // REQUIRED - Deep link URL for sharing comments

  // These fields are populated via JOINs with junction tables
  // They are NOT stored directly in the comments table
  subscribers?: User[]; // From comment_subscriptions junction table
  reactions?: Array<{
    // Aggregated from comment_reactions junction table
    // This structure is only used in API responses, not raw DB queries
    reaction: Reaction;
    users: User[];
    count: number;
  }>;

  createdAt: Date;
  updatedAt: Date;
}
