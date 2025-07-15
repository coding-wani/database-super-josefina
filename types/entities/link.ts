export interface Link {
  id: string;
  workspaceId: string; // For RLS
  issueId: string; // Foreign key to Issue.id
  title: string;
  url: string;
  description?: string; // Optional description from meta tags or user input
  createdAt: Date;
  updatedAt: Date;
}
