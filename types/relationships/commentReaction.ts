// =====================================================
// types/relationships/commentReaction.ts
// PURPOSE: Links users to comments with reactions(NB:1)
// DATABASE TABLE: comment_reactions
// 
// KEY CONCEPTS:
// - User can react to comments with emojis/reactions
// - One reaction per user per comment
// - Tracks when reaction was added
// - Links to reaction types/emojis
//
// NB:
// (1) RELATIONSHIP TYPE (Junction Table)
// This type represents a many-to-many relationship
// between users and comments with reaction metadata
// =====================================================

export interface CommentReaction {
  // ===== COMPOSITE PRIMARY KEY =====
  userId: string;          // User who reacted (VARCHAR(50))
  commentId: string;       // Comment being reacted to (UUID)
  
  // ===== FOREIGN KEY =====
  reactionId: string;      // Type of reaction/emoji (UUID)
  
  // ===== REACTION DATA =====
  reactedAt: Date;         // When reaction was added
}
