/**
 * Junction table linking users to issues they've favorited
 * Database table: issue_favorites
 * Primary key: (userId, issueId)
 */
export interface IssueFavorite {
  /** Foreign key to users.id */
  userId: string;
  /** Foreign key to issues.id */
  issueId: string;
  /** Timestamp when the issue was favorited */
  favoritedAt: Date;
}