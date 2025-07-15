CREATE TABLE IF NOT EXISTS issue_label_relations (
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    label_id UUID REFERENCES issue_labels(id) ON DELETE CASCADE,  -- Changed to UUID
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (issue_id, label_id)
);