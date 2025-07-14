"types" directory organization:

1. /api - API Response Types

Purpose:
Composed types that JOIN multiple entities

Characteristics:
Not stored in DB, used for API responses

Examples:
UserDashboardResponse, WorkspaceMembershipWithDetails

---

2. /entities - Core Database Entities

Purpose:
Direct representations of database tables

Characteristics:
Primary business objects with IDs

Examples:
User, Issue, Team, Workspace, Project

---

3. /enums - Enum/Union Types

Purpose:
Type constraints matching SQL CHECK constraints

Characteristics:
Simple type unions, no data just values

Examples:
Priority, Status, WorkspaceRole

---

4. /relationships - Junction/Membership Types

Purpose:
Many-to-many relationship representations

Characteristics:
Link entities together with additional data (role, joinedAt)

Examples:
WorkspaceMembership, TeamMembership
