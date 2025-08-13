// =====================================================
// types/enums/markerColor.ts
// PURPOSE: Color options for UI markers/badges
// NOT IN DATABASE - Frontend only
// 
// USE CASES:
// - Issue status badges
// - Priority indicators
// - Label backgrounds
// - Notification dots
// 
// SPECIAL VALUE:
// - "unread": Special state for notifications
// =====================================================

export type MarkerColor =
  | "unread"    // Special: indicates new/unseen
  | "red"       // Danger, urgent, blocked
  | "violet"    // Design, creative
  | "green"     // Success, done, approved
  | "yellow"    // Warning, in-progress
  | "blue"      // Info, default
  | "orange"    // Important, attention
  | "pink"      // Feature, enhancement
  | "purple"    // Epic, large scope
  | "gray"      // Disabled, archived
  | "brown";    // Misc, other