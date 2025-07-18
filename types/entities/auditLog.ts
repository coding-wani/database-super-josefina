/**
 * Audit log entity for tracking changes to important database records
 * Database table: audit_log
 * Automatically populated by database triggers on issues and projects tables
 */
export interface AuditLog {
  /** Primary key (UUID) */
  id: string;
  /** Name of the table that was changed */
  tableName: string;
  /** UUID of the record that was changed */
  recordId: string;
  /** Type of database operation performed */
  action: 'INSERT' | 'UPDATE' | 'DELETE';
  /** Foreign key to users.id - who performed the action (can be null for system actions) */
  userId?: string;
  /** JSONB data containing the changed record data (full record for INSERT/DELETE, old/new for UPDATE) */
  changedData?: Record<string, any>;
  /** Timestamp when the change occurred */
  createdAt: Date;
}