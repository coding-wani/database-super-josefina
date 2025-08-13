// =====================================================
// types/entities/issueLabel.ts
// PURPOSE: Categorization system for issues
// DATABASE TABLE: issue_labels
// 
// SCOPE:
// - Workspace-wide: teamId = NULL (all teams can use)
// - Team-specific: teamId set (only that team sees)
// =====================================================

export interface IssueLabel {
  // ===== IDENTIFIERS =====
  id: string;              // UUID
  
  // ===== SCOPE =====
  workspaceId: string;     // Labels belong to workspace
  teamId?: string;         // Optional team restriction
  
  // ===== DISPLAY =====
  name: string;            // Label text (unique per workspace)
  color: string;           // Hex color (#RRGGBB)
  description?: string;    // Optional explanation
  
  // ===== TIMESTAMPS =====
  createdAt: Date;
  updatedAt: Date;
}