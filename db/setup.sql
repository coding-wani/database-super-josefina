-- Run all schema files in order

\i schema/001_create_user_roles.sql
\i schema/002_create_workspaces.sql
\i schema/003_create_users.sql
\i schema/004_create_teams.sql
\i schema/005_create_projects.sql
\i schema/006_create_milestones.sql
\i schema/007_create_issues.sql
\i schema/008_create_comments.sql
\i schema/009_create_issue_labels.sql
\i schema/010_create_reactions.sql
\i schema/011_create_issue_label_relations.sql
\i schema/012_create_issue_subscriptions.sql
\i schema/013_create_comment_subscriptions.sql
\i schema/014_create_issue_favorites.sql
\i schema/015_create_comment_reactions.sql
\i schema/016_create_indexes.sql
\i schema/017_create_comment_issues.sql
\i schema/018_create_links.sql
\i schema/019_create_issue_related_issues.sql
\i schema/020_create_workspace_memberships.sql
\i schema/021_create_team_memberships.sql
\i schema/022_enable_rls.sql
\i schema/023_create_milestone_stats_view.sql
\i schema/024_create_user_role_assignment_events.sql
\i seeds/001_initial_reactions.sql