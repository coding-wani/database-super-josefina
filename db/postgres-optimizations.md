# PostgreSQL Optimizations for Issue Tracking Schema

## 1. 🎯 Partial Indexes (Huge Performance Gains)

Instead of indexing entire columns, create partial indexes for common query patterns:

```sql
-- Only index active issues (90% of queries filter out done/canceled)
CREATE INDEX idx_issues_active_status 
ON issues(status) 
WHERE status NOT IN ('done', 'canceled');

-- Index high-priority items for dashboard queries
CREATE INDEX idx_issues_high_priority_assignee 
ON issues(assignee_id, due_date) 
WHERE priority IN ('urgent', 'high') 
AND status NOT IN ('done', 'canceled');

-- Index overdue issues
CREATE INDEX idx_issues_overdue 
ON issues(assignee_id, due_date) 
WHERE due_date < NOW() 
AND status NOT IN ('done', 'canceled');

-- Index issues without assignee (for assignment queries)
CREATE INDEX idx_issues_unassigned 
ON issues(created_at DESC) 
WHERE assignee_id IS NULL 
AND status IN ('todo', 'backlog');
```

**Benefit**: These indexes are much smaller and faster than full-column indexes.

## 2. 🔍 Full-Text Search with GIN Indexes

Add PostgreSQL's powerful full-text search for issues and comments:

```sql
-- Add generated tsvector columns
ALTER TABLE issues 
ADD COLUMN search_vector tsvector 
GENERATED ALWAYS AS (
    setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(description, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(public_id, '')), 'A')
) STORED;

-- Create GIN index for ultra-fast text search
CREATE INDEX idx_issues_search ON issues USING GIN(search_vector);

-- Same for comments
ALTER TABLE comments 
ADD COLUMN search_vector tsvector 
GENERATED ALWAYS AS (
    to_tsvector('english', COALESCE(description, ''))
) STORED;

CREATE INDEX idx_comments_search ON comments USING GIN(search_vector);

-- Example search query
SELECT * FROM issues 
WHERE search_vector @@ plainto_tsquery('english', 'bug navigation')
ORDER BY ts_rank(search_vector, plainto_tsquery('english', 'bug navigation')) DESC;
```

## 3. 📊 JSONB for Flexible Metadata

Add JSONB columns for extensible data without schema changes:

```sql
-- Add metadata columns
ALTER TABLE issues ADD COLUMN metadata JSONB DEFAULT '{}';
ALTER TABLE users ADD COLUMN preferences JSONB DEFAULT '{}';
ALTER TABLE comments ADD COLUMN metadata JSONB DEFAULT '{}';

-- Index specific JSONB paths you query often
CREATE INDEX idx_issues_metadata_custom_fields 
ON issues USING GIN((metadata -> 'customFields'));

-- Index for user preferences
CREATE INDEX idx_users_preferences_theme 
ON users((preferences ->> 'theme'));

-- Example: Store custom fields, integrations data, etc.
UPDATE issues 
SET metadata = jsonb_build_object(
    'customFields', jsonb_build_object(
        'storyPoints', 5,
        'epicId', 'EPIC-123',
        'customerImpact', 'high'
    ),
    'integrations', jsonb_build_object(
        'jiraId', 'PROJ-4567',
        'githubPR', 'https://github.com/org/repo/pull/123'
    )
)
WHERE id = '550e8400-e29b-41d4-a716-446655440001';
```

## 4. 🚀 Materialized Views for Complex Queries

Pre-compute expensive aggregations:

```sql
-- Issue statistics materialized view
CREATE MATERIALIZED VIEW issue_stats_by_user AS
SELECT 
    u.id as user_id,
    u.username,
    COUNT(DISTINCT i.id) FILTER (WHERE i.assignee_id = u.id) as assigned_count,
    COUNT(DISTINCT i.id) FILTER (WHERE i.creator_id = u.id) as created_count,
    COUNT(DISTINCT i.id) FILTER (
        WHERE i.assignee_id = u.id 
        AND i.status = 'done' 
        AND i.updated_at > NOW() - INTERVAL '30 days'
    ) as completed_last_30_days,
    AVG(
        EXTRACT(EPOCH FROM (i.updated_at - i.created_at))/3600
    ) FILTER (
        WHERE i.assignee_id = u.id 
        AND i.status = 'done'
    ) as avg_completion_hours,
    COUNT(DISTINCT c.id) FILTER (WHERE c.author_id = u.id) as comment_count
FROM users u
LEFT JOIN issues i ON u.id IN (i.assignee_id, i.creator_id)
LEFT JOIN comments c ON u.id = c.author_id
GROUP BY u.id, u.username;

-- Create indexes on the materialized view
CREATE UNIQUE INDEX idx_issue_stats_user_id ON issue_stats_by_user(user_id);

-- Refresh periodically (could be triggered or scheduled)
REFRESH MATERIALIZED VIEW CONCURRENTLY issue_stats_by_user;
```

## 5. 🔒 Row-Level Security (RLS) for Multi-Tenant Safety

If you plan to support multiple teams/organizations:

```sql
-- Add team_id to relevant tables
ALTER TABLE users ADD COLUMN team_id UUID;
ALTER TABLE issues ADD COLUMN team_id UUID;
ALTER TABLE comments ADD COLUMN team_id UUID;

-- Enable RLS
ALTER TABLE issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY team_isolation_policy ON issues
    FOR ALL
    TO application_role
    USING (team_id = current_setting('app.current_team_id')::UUID);

-- In your application, set the team context:
-- SET LOCAL app.current_team_id = '550e8400-e29b-41d4-a716-446655440000';
```

## 6. 📈 Better Data Types and Constraints

```sql
-- Use more specific PostgreSQL types
ALTER TABLE issues 
    ALTER COLUMN priority TYPE VARCHAR(20) 
    USING priority::VARCHAR(20),
    ADD CONSTRAINT priority_not_empty CHECK (priority != '');

-- Add domain types for reusable constraints
CREATE DOMAIN email AS VARCHAR(255) 
    CHECK (VALUE ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

ALTER TABLE users ALTER COLUMN email TYPE email;

-- Use ENUM types instead of CHECK constraints for better performance
CREATE TYPE issue_status AS ENUM (
    'backlog', 'todo', 'in-progress', 'done', 'canceled', 'duplicate'
);

CREATE TYPE issue_priority AS ENUM (
    'no-priority', 'low', 'medium', 'high', 'urgent'
);

-- Convert existing columns (requires data migration)
-- ALTER TABLE issues ALTER COLUMN status TYPE issue_status USING status::issue_status;
-- ALTER TABLE issues ALTER COLUMN priority TYPE issue_priority USING priority::issue_priority;
```

## 7. 🎨 Generated Columns for Computed Values

```sql
-- Add computed columns that are automatically maintained
ALTER TABLE issues 
ADD COLUMN is_overdue BOOLEAN 
GENERATED ALWAYS AS (
    CASE 
        WHEN due_date IS NOT NULL 
        AND due_date < NOW() 
        AND status NOT IN ('done', 'canceled')
        THEN true 
        ELSE false 
    END
) STORED;

-- Add issue age in days
ALTER TABLE issues 
ADD COLUMN age_days INTEGER 
GENERATED ALWAYS AS (
    EXTRACT(DAY FROM NOW() - created_at)::INTEGER
) STORED;

-- Index these for fast filtering
CREATE INDEX idx_issues_overdue ON issues(is_overdue) WHERE is_overdue = true;
```

## 8. 📊 Table Partitioning for Scale

For very large tables, partition by date:

```sql
-- Convert comments to partitioned table (for high-volume systems)
CREATE TABLE comments_partitioned (
    LIKE comments INCLUDING ALL
) PARTITION BY RANGE (created_at);

-- Create monthly partitions
CREATE TABLE comments_2025_01 PARTITION OF comments_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE comments_2025_02 PARTITION OF comments_partitioned
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

-- Automated partition creation
CREATE OR REPLACE FUNCTION create_monthly_partition()
RETURNS void AS $$
DECLARE
    start_date date;
    end_date date;
    partition_name text;
BEGIN
    start_date := date_trunc('month', CURRENT_DATE);
    end_date := start_date + interval '1 month';
    partition_name := 'comments_' || to_char(start_date, 'YYYY_MM');
    
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF comments_partitioned 
         FOR VALUES FROM (%L) TO (%L)',
        partition_name, start_date, end_date
    );
END;
$$ LANGUAGE plpgsql;
```

## 9. 🔍 Exclusion Constraints for Business Rules

Prevent overlapping or conflicting data:

```sql
-- Ensure no duplicate active parent-child relationships
ALTER TABLE issue_related_issues 
ADD CONSTRAINT prevent_duplicate_relations 
EXCLUDE USING gist (
    int4range(LEAST(issue_id::text::int, related_issue_id::text::int), 
              GREATEST(issue_id::text::int, related_issue_id::text::int)) 
    WITH &&
);

-- Note: This is a simplified example. For UUIDs, you'd need a different approach
```

## 10. 📈 Performance Monitoring Setup

```sql
-- Create a table to track slow queries
CREATE TABLE IF NOT EXISTS query_performance_log (
    id SERIAL PRIMARY KEY,
    query_fingerprint TEXT,
    example_query TEXT,
    avg_duration_ms NUMERIC,
    calls BIGINT,
    total_duration_ms NUMERIC,
    logged_at TIMESTAMP DEFAULT NOW()
);

-- Function to log slow queries (called by pg_stat_statements)
CREATE OR REPLACE FUNCTION log_slow_queries()
RETURNS void AS $$
INSERT INTO query_performance_log (query_fingerprint, example_query, avg_duration_ms, calls, total_duration_ms)
SELECT 
    queryid::text,
    query,
    mean_exec_time,
    calls,
    total_exec_time
FROM pg_stat_statements
WHERE mean_exec_time > 100  -- queries slower than 100ms
ORDER BY mean_exec_time DESC
LIMIT 20;
$$ LANGUAGE sql;
```

## 11. 🚀 Connection Pooling Configuration

```sql
-- Optimized PostgreSQL configuration (postgresql.conf)
-- shared_buffers = 25% of RAM
-- effective_cache_size = 75% of RAM
-- work_mem = RAM / max_connections / 4
-- maintenance_work_mem = RAM / 16
-- max_connections = 100  # Keep low, use connection pooling

-- Create specific roles for connection pooling
CREATE ROLE app_read LOGIN PASSWORD 'secure_password';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read;

CREATE ROLE app_write LOGIN PASSWORD 'secure_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_write;
```

## 12. 🔧 Advanced Indexing Strategies

```sql
-- Covering indexes (include non-key columns)
CREATE INDEX idx_issues_list_view ON issues(status, created_at DESC) 
INCLUDE (title, public_id, priority, assignee_id)
WHERE status NOT IN ('done', 'canceled');

-- BRIN indexes for time-series data (much smaller than B-tree)
CREATE INDEX idx_issues_created_at_brin ON issues 
USING BRIN(created_at);

-- Hash indexes for equality comparisons only (faster than B-tree for =)
CREATE INDEX idx_users_email_hash ON users 
USING HASH(email);

-- Expression indexes for case-insensitive searches
CREATE INDEX idx_users_username_lower ON users(LOWER(username));
```

## 13. 🎯 Smarter Foreign Key Indexing

```sql
-- Deferrable constraints for bulk operations
ALTER TABLE issue_related_issues
    DROP CONSTRAINT issue_related_issues_issue_id_fkey,
    ADD CONSTRAINT issue_related_issues_issue_id_fkey 
        FOREIGN KEY (issue_id) REFERENCES issues(id) 
        ON DELETE CASCADE 
        DEFERRABLE INITIALLY IMMEDIATE;
```

## 14. 📊 Audit Trail with Temporal Tables

```sql
-- Create audit table
CREATE TABLE issues_audit (
    audit_id BIGSERIAL PRIMARY KEY,
    operation CHAR(1) NOT NULL CHECK (operation IN ('I', 'U', 'D')),
    audit_timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    audit_user VARCHAR(50),
    -- All columns from issues table
    LIKE issues,
    -- Period for temporal queries
    audit_period tstzrange NOT NULL
);

-- Create trigger for audit trail
CREATE OR REPLACE FUNCTION audit_issues() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO issues_audit 
        SELECT nextval('issues_audit_audit_id_seq'), 'I', NOW(), 
               current_setting('app.current_user', true), NEW.*, 
               tstzrange(NOW(), NULL);
    ELSIF TG_OP = 'UPDATE' THEN
        -- Close previous record
        UPDATE issues_audit 
        SET audit_period = tstzrange(lower(audit_period), NOW())
        WHERE id = NEW.id AND upper(audit_period) IS NULL;
        -- Insert new record
        INSERT INTO issues_audit 
        SELECT nextval('issues_audit_audit_id_seq'), 'U', NOW(), 
               current_setting('app.current_user', true), NEW.*, 
               tstzrange(NOW(), NULL);
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE issues_audit 
        SET audit_period = tstzrange(lower(audit_period), NOW())
        WHERE id = OLD.id AND upper(audit_period) IS NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_issues_trigger
AFTER INSERT OR UPDATE OR DELETE ON issues
FOR EACH ROW EXECUTE FUNCTION audit_issues();
```

## Summary of Benefits

1. **Partial Indexes**: 50-90% smaller indexes for common queries
2. **Full-Text Search**: Sub-millisecond search across all text fields
3. **JSONB**: Flexibility without schema migrations
4. **Materialized Views**: Pre-computed aggregations for dashboards
5. **Generated Columns**: Automatic computation of derived values
6. **Table Partitioning**: Scale to billions of records
7. **BRIN Indexes**: 99% smaller indexes for time-series data
8. **Covering Indexes**: Eliminate table lookups entirely

These optimizations can improve query performance by 10-100x depending on your data volume and query patterns.