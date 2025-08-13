// =====================================================
// types/relationships/issueFavorite.ts
// PURPOSE: Links users to issues they've favorited(NB:1)
// DATABASE TABLE: issue_favorites
// 
// KEY CONCEPTS:
// - Users can favorite/star issues
// - Quick access to important issues
// - Tracks when issue was favorited
// - Personal bookmarking system
//
// NB:
// (1) RELATIONSHIP TYPE (Junction Table)
// This type represents a many-to-many relationship
// between users and issues for bookmarking
// =====================================================

export interface IssueFavorite {
  // ===== COMPOSITE PRIMARY KEY =====
  userId: string;          // User who favorited (VARCHAR(50))
  issueId: string;         // Issue being favorited (UUID)
  
  // ===== FAVORITE DATA =====
  favoritedAt: Date;       // When issue was favorited
}
