// =====================================================
// types/api/commentWithReactions.ts
// PURPOSE: API response type for comments with reactions(NB:1)
// SOURCE TABLES: comments + comment_reactions + reactions + users
// 
// KEY CONCEPTS:
// - Aggregates comment data with reaction summaries
// - Groups reactions by type with user lists
// - Optimized for frontend display
// - Reduces API calls by pre-computing counts
//
// NB:
// (1) API RESPONSE TYPE (Composed Data)
// This type combines multiple database entities into
// a single response object for efficient API responses
// =====================================================

import { Comment } from "../entities/comment";
import { Reaction } from "../entities/reaction";
import { User } from "../entities/user";

export interface ReactionSummary {
  // ===== REACTION DATA =====
  reaction: Reaction;      // The emoji/reaction type
  users: User[];           // Users who reacted with this
  count: number;           // Total count for this reaction
}

export interface CommentWithReactions extends Omit<Comment, "reactions"> {
  // ===== COMMENT DATA =====
  // Inherits all Comment fields except 'reactions'
  
  // ===== AGGREGATED REACTION DATA =====
  reactions: ReactionSummary[];  // Grouped reactions with counts
}
