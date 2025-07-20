export interface CommentIssue {
  commentId: string; // UUID
  issueId: string; // UUID
  isSubIssue: boolean;
  createdAt: Date;
}
