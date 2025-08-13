// =====================================================
// types/enums/teamRole.ts
// PURPOSE: User roles within teams
// DATABASE: CHECK constraint on team_memberships.role
// 
// PERMISSION HIERARCHY:
// 1. lead: Manage team settings, edit all team content
// 2. member: Full team access, create/edit own content
// 3. viewer: Read-only access to team content
// 
// NOTES:
// - User must be workspace member to join team
// - Team leads can manage team members
// - Team-specific issues only visible to members
// =====================================================

export type TeamRole = "lead" | "member" | "viewer";