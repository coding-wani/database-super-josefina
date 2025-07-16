CREATE TABLE IF NOT EXISTS audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    user_id VARCHAR(50) REFERENCES users(id),
    old_data JSONB,
    new_data JSONB,
    changed_fields TEXT[],
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for audit log
CREATE INDEX idx_audit_log_table_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_log_user ON audit_log(user_id);
CREATE INDEX idx_audit_log_created_at ON audit_log(created_at DESC);
CREATE INDEX idx_audit_log_action ON audit_log(action);

-- Generic audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
DECLARE
    changed_fields TEXT[];
    old_json JSONB;
    new_json JSONB;
BEGIN
    -- Get the current user from the session
    -- This assumes the application sets app.current_user before operations
    
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (
            table_name, 
            record_id, 
            action, 
            user_id, 
            new_data,
            ip_address,
            user_agent
        )
        VALUES (
            TG_TABLE_NAME, 
            NEW.id, 
            TG_OP, 
            current_setting('app.current_user', true),
            row_to_json(NEW)::jsonb,
            inet(current_setting('app.client_ip', true)),
            current_setting('app.user_agent', true)
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        -- Calculate changed fields
        old_json := row_to_json(OLD)::jsonb;
        new_json := row_to_json(NEW)::jsonb;
        
        SELECT array_agg(key) INTO changed_fields
        FROM jsonb_each(old_json) o
        FULL OUTER JOIN jsonb_each(new_json) n USING (key)
        WHERE o.value IS DISTINCT FROM n.value;
        
        INSERT INTO audit_log (
            table_name, 
            record_id, 
            action, 
            user_id, 
            old_data, 
            new_data,
            changed_fields,
            ip_address,
            user_agent
        )
        VALUES (
            TG_TABLE_NAME, 
            NEW.id, 
            TG_OP, 
            current_setting('app.current_user', true),
            old_json,
            new_json,
            changed_fields,
            inet(current_setting('app.client_ip', true)),
            current_setting('app.user_agent', true)
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (
            table_name, 
            record_id, 
            action, 
            user_id, 
            old_data,
            ip_address,
            user_agent
        )
        VALUES (
            TG_TABLE_NAME, 
            OLD.id, 
            TG_OP, 
            current_setting('app.current_user', true),
            row_to_json(OLD)::jsonb,
            inet(current_setting('app.client_ip', true)),
            current_setting('app.user_agent', true)
        );
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create audit triggers for important tables
CREATE TRIGGER audit_issues
AFTER INSERT OR UPDATE OR DELETE ON issues
FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_comments
AFTER INSERT OR UPDATE OR DELETE ON comments
FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_projects
AFTER INSERT OR UPDATE OR DELETE ON projects
FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_users
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_workspaces
AFTER INSERT OR UPDATE OR DELETE ON workspaces
FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_teams
AFTER INSERT OR UPDATE OR DELETE ON teams
FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- View for easier audit log querying
CREATE VIEW audit_log_readable AS
SELECT 
    al.id,
    al.table_name,
    al.record_id,
    al.action,
    u.username as user_name,
    al.changed_fields,
    al.created_at,
    al.ip_address,
    al.user_agent,
    CASE 
        WHEN al.action = 'UPDATE' THEN 
            jsonb_pretty(al.new_data - al.old_data)
        WHEN al.action = 'INSERT' THEN 
            jsonb_pretty(al.new_data)
        WHEN al.action = 'DELETE' THEN 
            jsonb_pretty(al.old_data)
    END as changes
FROM audit_log al
LEFT JOIN users u ON al.user_id = u.id
ORDER BY al.created_at DESC;