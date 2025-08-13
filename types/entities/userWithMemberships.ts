// =====================================================
// types/entities/userWithMemberships.ts
// PURPOSE: Extended user type with memberships
// NOT A DATABASE TABLE - Composed type for convenience
// 
// USE CASE: Initial app load, user dashboard
// =====================================================

import { User } from "./user";
import { WorkspaceMembership } from "../relationships/workspaceMembership";
import { TeamMembership } from "../relationships/teamMembership";

// Extended user model that includes membership arrays
// Useful for avoiding multiple API calls
export interface UserWithMemberships extends User {
  workspaces: WorkspaceMembership[]; // All workspace memberships
  teams: TeamMembership[];            // All team memberships
}