# Issue Tracker Database & Types Repository

This repository contains the database schema, TypeScript models, and mock data for the issue tracker application. It's kept separate from the main application repository to maintain privacy of the database structure.

## 📁 Repository Structure

### `/db/` - Database Files
Complete PostgreSQL database setup with schema, queries, and seeds.

#### `/db/schema/` - Database Schema
SQL files that create all database tables, constraints, and features:
- `001_create_user_roles.sql` - Advanced user roles with JSONB permissions
- `002_create_workspaces.sql` - Workspace management + auto-update triggers
- `003_create_users.sql` - User accounts (OAuth compatible)
- `004_create_teams.sql` - Team organization within workspaces
- `005_create_projects.sql` - Project management with status/priority
- `006_create_milestones.sql` - Project milestones and goals
- `007_create_issues.sql` - Core issue tracking with hierarchy
- `008_create_comments.sql` - Issue comments with threading
- `009_create_issue_labels.sql` - Labeling system with color coding
- `010_create_reactions.sql` - Emoji reactions for comments
- `011-015_create_*_relations.sql` - Junction tables for many-to-many relationships
- `016_create_indexes.sql` - Performance optimization indexes
- `017-021_create_*.sql` - Additional features (links, memberships, etc.)
- `022_enable_rls.sql` - Row Level Security for data isolation
- `023_create_milestone_stats_view.sql` - Pre-calculated milestone statistics
- `024_create_user_role_assignments.sql` - Role assignment system

#### `/db/queries/` - Ready-to-Use SQL Queries
Simple, documented SQL queries for common application operations:
- `user-queries.sql` - User authentication, profiles, memberships
- `workspace-queries.sql` - Workspace and team management
- `issue-queries.sql` - Issue tracking and management
- `project-queries.sql` - Projects, milestones, and labels
- `README.md` - Usage instructions and examples

#### `/db/seeds/` - Initial Data
- `001_initial_reactions.sql` - Default emoji reactions

#### `/db/setup.sql` - Database Setup Script
Runs all schema files in the correct order for complete database setup.

### `/types/` - TypeScript Models
Complete type definitions matching the database schema.

#### `/types/entities/` - Core Entity Types
- `user.ts` - User account model
- `workspace.ts` - Workspace model
- `team.ts` - Team model
- `project.ts` - Project model with status/priority enums
- `milestone.ts` - Milestone model with progress tracking
- `issue.ts` - Issue model with hierarchy and relationships
- `comment.ts` - Comment model with threading
- `issueLabel.ts` - Label model with color coding
- `reaction.ts` - Emoji reaction model
- `link.ts` - External link attachments
- `userRole.ts` - Advanced role system
- `userRoleAssignment.ts` - Role assignment tracking
- `userWithMemberships.ts` - Extended user model for API responses

#### `/types/relationships/` - Junction Table Types
- `workspaceMembership.ts` - User-workspace relationships
- `teamMembership.ts` - User-team relationships
- `issueLabelRelation.ts` - Issue-label associations
- `issueSubscription.ts` - Issue notification subscriptions
- `commentSubscription.ts` - Comment notification subscriptions
- `issueFavorite.ts` - User's favorite issues
- `commentReaction.ts` - Comment emoji reactions
- `commentIssue.ts` - Issues created from comments
- `issueRelatedIssue.ts` - Issue-to-issue relationships

#### `/types/enums/` - Enumeration Types
- `priority.ts` - Issue/project priority levels
- `status.ts` - Issue status workflow
- `projectStatus.ts` - Project lifecycle status
- `workspaceRole.ts` - Workspace permission levels
- `teamRole.ts` - Team permission levels

#### `/types/api/` - API Response Types
Complex types for API endpoints combining multiple entities:
- `issueWithDetails.ts` - Issue with labels, comments, etc.
- `commentWithReactions.ts` - Comment with reaction counts
- `projectOverview.ts` - Project with milestone progress
- `userDashboardResponse.ts` - User dashboard data
- `workspaceAnalytics.ts` - Workspace statistics
- And more...

#### `/types/index.ts` - Main Export File
Central export point for all types.

### `/data/` - Mock Data for Testing
Realistic JSON mock data matching the database schema:
- `workspaces.json` - Sample workspaces
- `users.json` - Sample users with different roles
- `teams.json` - Sample teams across workspaces
- `projects.json` - Sample projects with different statuses
- `milestones.json` - Sample milestones with progress
- `issues.json` - Complex issue hierarchy with relationships
- `comments.json` - Threaded comments with replies
- `*_relations.json` - Junction table data for relationships
- And more... (21 files total)

### `/doc/` - Documentation
#### `/doc/types-db/` - Analysis and Documentation
- `/analyses/` - Consistency analysis reports
- `/learn/` - Database complexity analysis and learning materials

## 🔧 Key Features

### Security Features
- **Row Level Security (RLS)** - Automatic data isolation between workspaces
- **Advanced Role System** - JSONB permissions with workspace-specific roles
- **Multi-tenant Architecture** - Complete workspace isolation

### Performance Features
- **Optimized Indexes** - Strategic indexing for common queries
- **Pre-calculated Views** - Milestone statistics and progress tracking
- **Efficient Relationships** - Proper junction tables for many-to-many relations

### Developer Experience
- **Type Safety** - Complete TypeScript coverage
- **Ready-to-use Queries** - No need to write complex SQL
- **Realistic Mock Data** - 21 files of interconnected test data
- **Comprehensive Documentation** - Analysis reports and guides

## 🚀 Getting Started

### 1. Database Setup
```bash
# Run the complete database setup
psql -d your_database -f db/setup.sql
```

### 2. TypeScript Integration
```typescript
import { Issue, User, Project } from './types';
```

### 3. Using Queries
```javascript
// Example: Get user with memberships
const user = await db.query(userQueries.getUserById, [userId]);
const workspaces = await db.query(userQueries.getUserWorkspaces, [userId]);
```

### 4. Mock Data for Development
Use the JSON files in `/data/` for frontend development and testing.

## 🔒 Security Implementation Required

**Important**: The RLS (Row Level Security) system requires your application to set the current user context:

```javascript
// Before each database operation
await db.query("SET app.current_user = $1", [currentUserId]);
```

See `/doc/types-db/analyses/` for detailed implementation guides.

## 📊 Data Consistency

All components are verified for consistency:
- ✅ SQL schema ↔ TypeScript types
- ✅ TypeScript types ↔ Mock data  
- ✅ Relationships and constraints
- ✅ Enumerations and formats

## 🎯 Architecture Decisions

- **Separate Repository** - Keeps database structure private
- **UUID Primary Keys** - Better for distributed systems
- **JSONB Permissions** - Flexible role-based access control
- **Bidirectional Relations** - Automatic two-way issue relationships
- **Workspace Isolation** - Complete multi-tenancy support

This repository provides a complete, production-ready database foundation for a modern issue tracking application.