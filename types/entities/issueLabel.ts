export interface IssueLabel {
  id: string;
  workspaceId: string; // Labels are workspace-specific
  teamId?: string; // Optional: labels can be team-specific
  name: string;
  color: string; // hex color
  description?: string;
}
