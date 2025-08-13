// =====================================================
// types/relationships/commentSubscription.ts
// PURPOSE: Links users to comments for notifications(NB:1)
// DATABASE TABLE: comment_subscriptions
// 
// KEY CONCEPTS:
// - User subscribes to comment threads
// - Gets notified of new replies/reactions
// - Tracks when subscription was created
// - Enables granular notification control
//
// NB:
// (1) RELATIONSHIP TYPE (Junction Table)
// This type represents a many-to-many relationship
// between users and comments for notification preferences
// =====================================================

export interface CommentSubscription {
  // ===== COMPOSITE PRIMARY KEY =====
  userId: string;          // User subscribing (VARCHAR(50))
  commentId: string;       // Comment thread to follow (UUID)
  
  // ===== SUBSCRIPTION DATA =====
  subscribedAt: Date;      // When subscription was created
}
