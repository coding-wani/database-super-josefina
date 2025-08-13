// =====================================================
// types/relationships/issueLabelRelation.ts
// PURPOSE: Links issues to labels for categorization(NB:1)
// DATABASE TABLE: issue_label_relations
// 
// KEY CONCEPTS:
// - Issues can have multiple labels
// - Labels can be applied to multiple issues
// - Tracks when label was applied
// - Enables filtering and organization
//
// NB:
// (1) RELATIONSHIP TYPE (Junction Table)
// This type represents a many-to-many relationship
// between issues and labels for categorization
// =====================================================

export interface IssueLabelRelation {
  // ===== COMPOSITE PRIMARY KEY =====
  issueId: string;         // Issue being labeled (UUID)
  labelId: string;         // Label being applied (UUID)
  
  // ===== RELATION DATA =====
  createdAt: Date;         // When label was applied
}
