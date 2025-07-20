import { Comment } from "../entities/comment";
import { Reaction } from "../entities/reaction";
import { User } from "../entities/user";

// ===== API RESPONSE TYPE (Composed from DB models) =====
// This type represents a comment with aggregated reaction data
// The database stores individual reactions in comment_reactions junction table
// This type is used when returning comments with reaction summaries

export interface ReactionSummary {
  reaction: Reaction;
  users: User[];
  count: number;
}

export interface CommentWithReactions extends Omit<Comment, "reactions"> {
  reactions: ReactionSummary[];
}
