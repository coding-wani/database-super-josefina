// =====================================================
// types/relationships/teamMembership.ts
// PURPOSE: Links users to teams with roles(NB:1)
// DATABASE TABLE: team_memberships
// 
// KEY CONCEPTS:
// - User can be in multiple teams
// - Different role per team (admin, member)
// - Tracks when user joined team
// - Team-level permissions and access
//
// NB:
// (1) RELATIONSHIP TYPE (Junction Table)
// This type represents a many-to-many relationship
// between users and teams with role metadata
// =====================================================

import { TeamRole } from "../enums/teamRole";

export interface TeamMembership {
  // ===== PRIMARY KEY =====
  id: string;              // UUID
  
  // ===== FOREIGN KEYS =====
  userId: string;          // User in team (VARCHAR(50))
  teamId: string;          // Team they belong to (UUID)
  
  // ===== MEMBERSHIP DATA =====
  role: TeamRole;          // admin or member
  joinedAt: Date;          // When they joined team
}
