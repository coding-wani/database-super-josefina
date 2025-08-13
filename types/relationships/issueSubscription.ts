// =====================================================
// types/relationships/issueSubscription.ts
// PURPOSE: Links users to issues for notifications(NB:1)
// DATABASE TABLE: issue_subscriptions
// 
// KEY CONCEPTS:
// - Users subscribe to issue updates
// - Gets notified of status changes, comments
// - Tracks when subscription was created
// - Enables following important issues
//
// NB:
// (1) RELATIONSHIP TYPE (Junction Table)
// This type represents a many-to-many relationship
// between users and issues for notification preferences
// =====================================================

export interface IssueSubscription {
  // ===== COMPOSITE PRIMARY KEY =====
  userId: string;          // User subscribing (VARCHAR(50))
  issueId: string;         // Issue to follow (UUID)
  
  // ===== SUBSCRIPTION DATA =====
  subscribedAt: Date;      // When subscription was created
}
