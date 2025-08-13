// =====================================================
// types/entities/reaction.ts
// PURPOSE: Emoji library for comment reactions
// DATABASE TABLE: reactions
// 
// NOTES:
// - System-wide (not workspace-scoped)
// - Predefined set of emojis
// - Used via comment_reactions junction table
// =====================================================

export interface Reaction {
  // ===== IDENTIFIERS =====
  id: string;              // UUID
  
  // ===== CONTENT =====
  emoji: string;           // The actual emoji (e.g., "🥰", "👍")
  name: string;            // Unique code (e.g., "heart_eyes", "thumbs_up")
                          // Used for :emoji: shortcuts
  
  // ===== TIMESTAMPS =====
  createdAt: Date;
  updatedAt: Date;
}