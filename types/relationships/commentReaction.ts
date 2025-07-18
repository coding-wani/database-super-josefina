/**
 * Junction table linking users to their reactions on comments
 * Database table: comment_reactions
 * Primary key: (userId, commentId, reactionId)
 */
export interface CommentReaction {
  /** Foreign key to users.id */
  userId: string;
  /** Foreign key to comments.id */
  commentId: string;
  /** Foreign key to reactions.id */
  reactionId: string;
  /** Timestamp when the reaction was added */
  reactedAt: Date;
}