export interface Link {
  id: string;
  issueId: string; // Foreign key to Issue.id
  title: string;
  url: string;
  createdAt: Date;
  updatedAt: Date;
}
