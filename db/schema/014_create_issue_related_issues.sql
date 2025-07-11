-- db/schema/014_create_issue_related_issues.sql

CREATE TABLE IF NOT EXISTS issue_related_issues (
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    related_issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (issue_id, related_issue_id),
    -- Ensure an issue cannot be related to itself
    CONSTRAINT no_self_relation CHECK (issue_id != related_issue_id)
);

-- Indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_issue_related_issues_issue ON issue_related_issues(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_related_issues_related ON issue_related_issues(related_issue_id);

-- Function to maintain bidirectional consistency
CREATE OR REPLACE FUNCTION maintain_issue_relations() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Insert the reverse relation
        INSERT INTO issue_related_issues (issue_id, related_issue_id, created_at)
        VALUES (NEW.related_issue_id, NEW.issue_id, NEW.created_at)
        ON CONFLICT DO NOTHING;
    ELSIF TG_OP = 'DELETE' THEN
        -- Delete the reverse relation
        DELETE FROM issue_related_issues 
        WHERE issue_id = OLD.related_issue_id AND related_issue_id = OLD.issue_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically maintain bidirectional relations
CREATE TRIGGER maintain_bidirectional_relations
AFTER INSERT OR DELETE ON issue_related_issues
FOR EACH ROW
EXECUTE FUNCTION maintain_issue_relations();