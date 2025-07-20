export interface IssueFavorite {
  userId: string; // VARCHAR(50) - OAuth compatible
  issueId: string; // UUID
  favoritedAt: Date;
}
