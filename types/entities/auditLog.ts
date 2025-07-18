export interface AuditLog {
  id: string; // UUID
  tableName: string; // Which table was changed
  recordId: string; // UUID - Which record was changed
  action: 'INSERT' | 'UPDATE' | 'DELETE'; // What happened
  userId?: string; // Who did it (VARCHAR(50) - can be null)
  changedData?: Record<string, any>; // JSONB - What was changed (stores the data as JSON)
  createdAt: Date;
}