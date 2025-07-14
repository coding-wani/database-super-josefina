CREATE TABLE IF NOT EXISTS issue_label_relations (
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    label_id VARCHAR(50) REFERENCES issue_labels(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (issue_id, label_id)
);