import { TeamRole } from "./teamRole";

export interface TeamMembership {
  id: string; // UUID
  userId: string; // Foreign key to User
  teamId: string; // Foreign key to Team
  role: TeamRole;
  joinedAt: Date;
}
