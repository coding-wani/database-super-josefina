CREATE TABLE IF NOT EXISTS links (
    id VARCHAR(50) PRIMARY KEY,
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    url TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_links_issue ON links(issue_id);
CREATE INDEX IF NOT EXISTS idx_links_created_at ON links(created_at DESC);

CREATE TRIGGER update_links_updated_at BEFORE UPDATE
    ON links FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();