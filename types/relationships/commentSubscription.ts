export interface CommentSubscription {
  userId: string; // VARCHAR(50) - OAuth compatible
  commentId: string; // UUID
  subscribedAt: Date;
}
