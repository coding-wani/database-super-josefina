-- Simple audit log to track changes
-- This helps you see who changed what and when

CREATE TABLE IF NOT EXISTS audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(50) NOT NULL,     -- Which table was changed
    record_id UUID NOT NULL,              -- Which record was changed
    action VARCHAR(20) NOT NULL,          -- What happened: INSERT, UPDATE, or DELETE
    user_id VARCHAR(50),                  -- Who did it
    changed_data JSONB,                   -- What was changed (stores the data as JSON)
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Index to find changes quickly
CREATE INDEX idx_audit_log_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_log_created ON audit_log(created_at DESC);

-- Simple trigger to track changes on issues table
-- You can add this to other important tables later
CREATE OR REPLACE FUNCTION simple_audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, record_id, action, user_id, changed_data)
        VALUES (
            TG_TABLE_NAME, 
            NEW.id, 
            'INSERT',
            current_setting('app.current_user', true),  -- Your app needs to set this
            row_to_json(NEW)::jsonb
        );
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, record_id, action, user_id, changed_data)
        VALUES (
            TG_TABLE_NAME, 
            NEW.id, 
            'UPDATE',
            current_setting('app.current_user', true),
            jsonb_build_object(
                'old', row_to_json(OLD),
                'new', row_to_json(NEW)
            )
        );
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, record_id, action, user_id, changed_data)
        VALUES (
            TG_TABLE_NAME, 
            OLD.id, 
            'DELETE',
            current_setting('app.current_user', true),
            row_to_json(OLD)::jsonb
        );
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Add audit tracking to important tables
CREATE TRIGGER audit_issues
AFTER INSERT OR UPDATE OR DELETE ON issues
FOR EACH ROW EXECUTE FUNCTION simple_audit_trigger();

CREATE TRIGGER audit_projects
AFTER INSERT OR UPDATE OR DELETE ON projects
FOR EACH ROW EXECUTE FUNCTION simple_audit_trigger();

-- You can add more tables later as needed