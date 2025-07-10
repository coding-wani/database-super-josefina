import { User } from "./user";
import { Reaction } from "./reaction";

export interface Comment {
  id: string;
  authorId: string; // Foreign key to User.id
  description: string; // The comment content (markdown)
  parentIssueId: string; // Foreign key to Issue.id
  parentCommentId?: string; // Foreign key to Comment.id (for replies)
  threadOpen: boolean;
  commentUrl: string;
  subscribers?: User[]; // Array of subscribed users (populated via junction table)
  reactions?: Array<{
    // Array of reactions with user info
    reaction: Reaction;
    users: User[];
    count: number;
  }>;
  createdAt: Date;
  updatedAt: Date;
}
