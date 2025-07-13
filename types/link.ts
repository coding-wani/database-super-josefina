export interface Link {
  id: string;
  workspaceId: string; // For RLS
  issueId: string; // Foreign key to Issue.id
  title: string;
  url: string;
  createdAt: Date;
  updatedAt: Date;
}
