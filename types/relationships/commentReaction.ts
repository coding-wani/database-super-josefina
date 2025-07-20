export interface CommentReaction {
  userId: string; // VARCHAR(50) - OAuth compatible
  commentId: string; // UUID
  reactionId: string; // UUID
  reactedAt: Date;
}
