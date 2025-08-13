// =====================================================
// types/entities/userRoleAssignmentEvent.ts
// PURPOSE: Audit log for role changes
// DATABASE TABLE: user_role_assignment_events
// 
// IMPORTANT: This is an EVENT LOG, not current state!
// - Tracks complete history of role assignments
// - Immutable audit trail
// - Used for compliance and activity feeds
// =====================================================

/**
 * Event log entity that records the complete history of user role assignments.
 * 
 * IMPORTANT: This is an EVENT LOG TABLE, not a simple relationship table.
 * It tracks ALL assignment/removal/expiration events over time for audit trails
 * and activity feeds. Each record represents a historical event that occurred,
 * not just current relationships.
 * 
 * This is why this type is in /entities/ rather than /relationships/.
 * 
 * QUERY EXAMPLE:
 * To find current roles: Filter by action='assigned' and no subsequent 'removed'
 * To audit changes: Sort by createdAt DESC
 * To find who assigned: Check assignedBy field
 */
export interface UserRoleAssignmentEvent {
  // ===== IDENTIFIERS =====
  id: string;              // UUID (internal)
  publicId: string;        // Event ID (e.g., "ROLE-EVT-001")
  
  // ===== EVENT DATA =====
  userId: string;          // User receiving role (VARCHAR(50))
  roleId: string;          // Role being assigned (UUID)
  workspaceId?: string;    // For workspace-specific roles
  
  // ===== EVENT TYPE =====
  action: "assigned" | "removed" | "expired";
  
  // ===== METADATA =====
  assignedBy?: string;     // User who performed action (VARCHAR(50))
                          // NULL for system actions
  
  // ===== TIMESTAMPS =====
  createdAt: Date;         // When event occurred
  expiresAt?: Date;        // For temporary roles
}