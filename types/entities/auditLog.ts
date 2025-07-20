export interface AuditLog {
  id: string; // UUID
  tableName: string; // Which table was changed
  recordId: string; // UUID - Which record was changed
  action: "INSERT" | "UPDATE" | "DELETE"; // What happened
  userId?: string; // VARCHAR(50) - Who did it (optional as it might be system)
  changedData?: any; // JSONB - What was changed (stores the data as JSON)
  createdAt: Date;
}
