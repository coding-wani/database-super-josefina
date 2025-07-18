/**
 * Junction table linking users to comments they're subscribed to for notifications
 * Database table: comment_subscriptions
 * Primary key: (userId, commentId)
 */
export interface CommentSubscription {
  /** Foreign key to users.id */
  userId: string;
  /** Foreign key to comments.id */
  commentId: string;
  /** Timestamp when the subscription was created */
  subscribedAt: Date;
}