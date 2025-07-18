/**
 * Junction table linking comments to issues they reference or create
 * Database table: comment_issues
 * Primary key: (commentId, issueId)
 */
export interface CommentIssue {
  /** Foreign key to comments.id */
  commentId: string;
  /** Foreign key to issues.id */
  issueId: string;
  /** Whether this creates a sub-issue relationship */
  isSubIssue: boolean;
  /** Timestamp when the relation was created */
  createdAt: Date;
}