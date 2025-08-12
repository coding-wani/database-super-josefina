# Seed Files Documentation

## Overview
Seed files are numbered to ensure correct execution order due to foreign key dependencies.
**DO NOT reorganize into subdirectories** - the numbered sequence is critical for database initialization.

## File Categories and Dependencies

### 🏗️ Foundation (Core Entities)
These files create the base data that other seeds depend on:

| File | Purpose | Dependencies | Creates |
|------|---------|--------------|---------|
| 001_initial_reactions.sql | System reactions/emojis | None | 12 reaction types |
| 002_seed_workspaces.sql | Workspace setup | None | 2 workspaces |
| 003_seed_user_roles.sql | Role definitions | None | 1 custom role (4 system roles exist) |
| 004_seed_users.sql | User accounts | 002 (workspaces) | 5 users |

### 🏢 Organization Structure
Sets up teams and projects:

| File | Purpose | Dependencies | Creates |
|------|---------|--------------|---------|
| 006_seed_teams.sql | Team creation | 002 (workspaces) | 3 teams |
| 008_seed_projects.sql | Project setup | 006 (teams), 004 (users) | 2 projects |
| 009_seed_milestones.sql | Milestone creation | 008 (projects) | 3 milestones |
| 010_seed_issue_labels.sql | Label definitions | 002 (workspaces), 006 (teams) | 4 labels |

### 📋 Issues and Content
Core content and discussions:

| File | Purpose | Dependencies | Creates |
|------|---------|--------------|---------|
| 011_seed_issues.sql | Issue creation | 004 (users), 006 (teams), 008 (projects), 009 (milestones) | 14 issues (12 published, 2 drafts) |
| 012_seed_comments.sql | Comments on issues | 011 (issues), 004 (users) | 3 comments |
| 020_seed_links.sql | External links | 011 (issues) | 6 links |

### 🔗 Relationships (Junction Tables)
Links entities together with additional metadata:

| File | Purpose | Dependencies | Creates |
|------|---------|--------------|---------|
| 005_seed_workspace_memberships.sql | User-workspace links | 002 (workspaces), 004 (users) | 6 memberships |
| 007_seed_team_memberships.sql | User-team links | 006 (teams), 004 (users) | 5 memberships |
| 014_seed_comment_reactions.sql | Reaction assignments | 012 (comments), 001 (reactions), 004 (users) | 6 reactions |
| 015_seed_issue_label_relations.sql | Issue-label links | 011 (issues), 010 (labels) | 5 relations |
| 016_seed_issue_subscriptions.sql | Issue subscriptions | 011 (issues), 004 (users) | 5 subscriptions |
| 017_seed_issue_favorites.sql | Favorited issues | 011 (issues), 004 (users) | 5 favorites |
| 018_seed_comment_subscriptions.sql | Comment subscriptions | Currently empty | 0 subscriptions |
| 019_seed_issue_related_issues.sql | Issue relationships | 011 (issues) | 3 bidirectional relations |

### 📝 Event/Audit Tables
Historical tracking and audit trails:

| File | Purpose | Dependencies | Creates |
|------|---------|--------------|---------|
| 013_seed_user_role_assignment_events.sql | Role assignment history | 003 (roles), 004 (users) | 5 assignment events |

## Execution Order Rationale

The numbering ensures:

1. **No foreign key violations**: Parents exist before children
2. **Logical data flow**: Workspaces → Teams → Projects → Issues → Comments
3. **Relationship integrity**: Entities exist before their relationships
4. **Event accuracy**: Events reference existing entities

## Important Notes

### Why Not Use Subdirectories?

1. **Dependencies cross categories**: Team memberships (relationship) need teams (entity)
2. **Execution order matters more than categorization**: File 005 MUST run after 004
3. **Single command execution**: `\i db/setup.sql` runs everything in order
4. **Version control**: Git shows changes in chronological/dependency order

### Empty Files

- `018_seed_comment_subscriptions.sql`: Placeholder for future comment subscription features

### Special Patterns

- **Predictable UUIDs**: Some seeds use specific UUIDs for testing (e.g., '550e8400-e29b-41d4-a716-446655440XXX')
- **ON CONFLICT DO NOTHING**: Allows re-running seeds safely
- **Bidirectional relations**: File 019 uses triggers to maintain consistency

## Adding New Seed Files

When adding new seeds:

1. **Number it correctly**: Next number in sequence (021, 022, etc.)
2. **Check dependencies**: List all tables that must exist first
3. **Update this document**: Add entry to appropriate category
4. **Update setup.sql**: Add the `\i` statement in order
5. **Use ON CONFLICT**: Ensure idempotency

## Testing Seeds

```bash
# Reset and reseed database
psql -U user -d test_db -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
psql -U user -d test_db -f db/setup.sql

# Verify counts
psql -U user -d test_db -c "
  SELECT 'users' as table, COUNT(*) FROM users
  UNION ALL SELECT 'issues', COUNT(*) FROM issues
  UNION ALL SELECT 'comments', COUNT(*) FROM comments;
"
```