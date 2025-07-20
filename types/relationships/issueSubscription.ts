export interface IssueSubscription {
  userId: string; // VARCHAR(50) - OAuth compatible
  issueId: string; // UUID
  subscribedAt: Date;
}
