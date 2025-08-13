// =====================================================
// types/relationships/issueRelatedIssue.ts
// PURPOSE: Links issues to other related issues(NB:1)
// DATABASE TABLE: issue_related_issues
// 
// KEY CONCEPTS:
// - Issues can be related to other issues
// - Supports dependencies, blocking, duplicates
// - Bidirectional relationships possible
// - Tracks when relationship was created
//
// NB:
// (1) RELATIONSHIP TYPE (Junction Table)
// This type represents a many-to-many relationship
// between issues for cross-referencing and dependencies
// =====================================================

export interface IssueRelatedIssue {
  // ===== COMPOSITE PRIMARY KEY =====
  issueId: string;         // Source issue (UUID)
  relatedIssueId: string;  // Related/linked issue (UUID)
  
  // ===== RELATION DATA =====
  createdAt: Date;         // When relationship was created
}
