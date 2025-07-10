-- db/setup.sql
-- Run all schema files in order

\i schema/001_create_users.sql
\i schema/002_create_issues.sql
\i schema/003_create_comments.sql
\i schema/004_create_issue_labels.sql
\i schema/005_create_reactions.sql
\i schema/006_create_issue_label_relations.sql
\i schema/007_create_issue_subscriptions.sql
\i schema/008_create_comment_subscriptions.sql
\i schema/009_create_issue_favorites.sql
\i schema/010_create_comment_reactions.sql
\i schema/011_create_indexes.sql
\i schema/012_create_comment_issues.sql
\i seeds/001_initial_reactions.sql