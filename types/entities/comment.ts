// =====================================================
// types/entities/comment.ts
// PURPOSE: Threaded discussions on issues
// DATABASE TABLE: comments
// 
// FEATURES:
// - Supports nested replies via parent_comment_id
// - Emoji reactions via junction table
// - Thread locking (thread_open flag)
// - Deep linking for notifications
// =====================================================

import { User } from "./user";
import { Reaction } from "./reaction";

export interface Comment {
  // ===== IDENTIFIERS =====
  id: string;              // UUID
  
  // ===== MULTI-TENANCY =====
  workspaceId: string;     // For RLS (Row-Level Security)
  teamId?: string;         // Inherited from parent issue's team
  
  // ===== CONTENT =====
  authorId: string;        // User who wrote comment (VARCHAR(50))
  description: string;     // Comment content (Markdown)
  
  // ===== RELATIONSHIPS =====
  parentIssueId: string;   // Issue this comment belongs to
  parentCommentId?: string; // For replies (creates thread)
  
  // ===== FEATURES =====
  threadOpen: boolean;     // Can replies be added?
  commentUrl: string;      // Deep link for sharing/notifications
                          // e.g., "https://app.com/issue/ISSUE-04#comment-1"
  
  /**
   * ===== POPULATED VIA JOINS =====
   * These fields come from junction tables
   */
  
  // Users subscribed to this comment thread
  subscribers?: User[];    // From comment_subscriptions
  
  /**
   * Aggregated reactions from comment_reactions junction table.
   * 
   * STRUCTURE IN API:
   * reactions: [
   *   { reaction: {emoji: "👍", name: "thumbs_up"}, 
   *     users: [user1, user2], 
   *     count: 2 }
   * ]
   * 
   * STORAGE IN DB:
   * comment_reactions table with (user_id, comment_id, reaction_id)
   */
  reactions?: Array<{
    reaction: Reaction;
    users: User[];
    count: number;
  }>;
  
  // ===== TIMESTAMPS =====
  createdAt: Date;
  updatedAt: Date;
}