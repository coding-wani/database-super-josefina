// =====================================================
// types/entities/link.ts
// PURPOSE: External URL attachments for issues
// DATABASE TABLE: links
// 
// USE CASES:
// - Documentation links
// - Design mockups
// - Customer requests
// - Related articles
// =====================================================

export interface Link {
  // ===== IDENTIFIERS =====
  id: string;              // UUID
  
  // ===== RELATIONSHIPS =====
  workspaceId: string;     // For RLS
  issueId: string;         // Parent issue UUID
  
  // ===== CONTENT =====
  title: string;           // Link display text
  url: string;             // External URL
  description?: string;    // From meta tags or user input
  
  // ===== TIMESTAMPS =====
  createdAt: Date;
  updatedAt: Date;
}