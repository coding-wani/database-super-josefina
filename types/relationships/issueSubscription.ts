/**
 * Junction table linking users to issues they're subscribed to for notifications
 * Database table: issue_subscriptions
 * Primary key: (userId, issueId)
 */
export interface IssueSubscription {
  /** Foreign key to users.id */
  userId: string;
  /** Foreign key to issues.id */
  issueId: string;
  /** Timestamp when the subscription was created */
  subscribedAt: Date;
}