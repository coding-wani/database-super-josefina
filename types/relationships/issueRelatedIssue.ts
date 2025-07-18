/**
 * Junction table linking issues to other related issues (bidirectional)
 * Database table: issue_related_issues
 * Primary key: (issueId, relatedIssueId)
 * Note: Database maintains bidirectional consistency via triggers
 */
export interface IssueRelatedIssue {
  /** Foreign key to issues.id */
  issueId: string;
  /** Foreign key to issues.id (the related issue) */
  relatedIssueId: string;
  /** Timestamp when the relation was created */
  createdAt: Date;
}