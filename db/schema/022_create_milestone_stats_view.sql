-- New file: db/schema/022_create_milestone_stats_view.sql

CREATE OR REPLACE VIEW milestone_stats AS
SELECT 
    m.id AS milestone_id,
    m.public_id,
    m.project_id,
    m.title,
    COUNT(i.id) AS total_issues,
    COUNT(CASE WHEN i.status = 'triage' THEN 1 END) AS triage_count,
    COUNT(CASE WHEN i.status = 'backlog' THEN 1 END) AS backlog_count,
    COUNT(CASE WHEN i.status = 'todo' THEN 1 END) AS todo_count,
    COUNT(CASE WHEN i.status = 'planning' THEN 1 END) AS planning_count,
    COUNT(CASE WHEN i.status = 'in-progress' THEN 1 END) AS in_progress_count,
    COUNT(CASE WHEN i.status = 'in-review' THEN 1 END) AS in_review_count,
    COUNT(CASE WHEN i.status = 'done' THEN 1 END) AS done_count,
    COUNT(CASE WHEN i.status = 'commit' THEN 1 END) AS commit_count,
    COUNT(CASE WHEN i.status = 'canceled' THEN 1 END) AS canceled_count,
    COUNT(CASE WHEN i.status = 'decline' THEN 1 END) AS decline_count,
    COUNT(CASE WHEN i.status = 'duplicate' THEN 1 END) AS duplicate_count,
    -- Progress percentage (done + commit / total * 100)
    CASE 
        WHEN COUNT(i.id) > 0 
        THEN ROUND(((COUNT(CASE WHEN i.status = 'done' THEN 1 END) + COUNT(CASE WHEN i.status = 'commit' THEN 1 END))::NUMERIC / COUNT(i.id)::NUMERIC) * 100, 2)
        ELSE 0
    END AS progress_percentage
FROM milestones m
LEFT JOIN issues i ON i.milestone_id = m.id
GROUP BY m.id, m.public_id, m.project_id, m.title;

-- Grant select permissions on the view
GRANT SELECT ON milestone_stats TO PUBLIC;