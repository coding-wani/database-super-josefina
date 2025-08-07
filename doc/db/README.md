# Issue Tracker Database Repository

## Overview
This private repository contains the complete database schema, TypeScript type definitions, and data fixtures for our issue tracking system. It's designed with type safety, performance, and maintainability in mind.

## 📁 Repository Structure

```
├── types/              # TypeScript type definitions
│   ├── entities/       # Core database entities
│   ├── enums/          # Enum/union types
│   ├── relationships/  # Junction table types
│   └── api/           # API response types
├── db/                # SQL database files
│   ├── schema/        # Table definitions
│   ├── queries/       # Common SQL queries
│   └── seeds/         # Initial data
├── data/              # JSON mockup/test data
└── doc/               # Documentation and analyses
```

## 🎯 Key Features

### Type Safety
- Complete TypeScript definitions for all database entities
- Enum types that match SQL CHECK constraints exactly
- API response types optimized for minimal database queries

### Performance Optimized
- API types designed to reduce database round trips
- Efficient indexes on all foreign keys
- Milestone statistics view for quick progress tracking
- Strategic indexing for common query patterns

### Data Integrity & Security
- Comprehensive foreign key constraints
- Business logic enforced at database level
- Automatic timestamp management via triggers
- Bidirectional relationship consistency (e.g., related issues)
- Row Level Security (RLS) for multi-tenant isolation
- Advanced role system with JSONB permissions

## 📊 Database Schema

### Core Entities
- **Users**: OAuth-compatible with VARCHAR(50) IDs
- **Workspaces**: Multi-tenant isolation
- **Teams**: With optional estimation settings (fibonacci, t-shirt, etc.)
- **Projects**: Hierarchical organization with milestones
- **Issues**: Full issue tracking with 11 status types
- **Comments**: Threaded discussions with reactions
- **Labels**: Workspace or team-scoped categorization
- **User Roles**: Advanced permission system with workspace-specific roles

### Issue Status Types
```typescript
type Status = "triage" | "backlog" | "todo" | "planning" | 
              "in-progress" | "in-review" | "done" | "commit" | 
              "canceled" | "decline" | "duplicate"
```

### Key Relationships
- Users belong to multiple workspaces and teams
- Issues can have parent issues (sub-tasks) or be created from comments
- Comments support threading and reactions
- Issues support labels, subscriptions, favorites, and related issues
- Bidirectional issue relationships with automatic consistency

## 🔧 Technical Details

### Field Naming Convention

The repository uses different naming conventions for different layers:
- **SQL**: `snake_case` (e.g., `workspace_id`, `created_at`)
- **TypeScript/JSON**: `camelCase` (e.g., `workspaceId`, `createdAt`)

### Conversion Functions

```javascript
// Convert JSON to SQL (for INSERT operations)
function jsonToSql(jsonObj) {
  const sqlObj = {};
  for (const [key, value] of Object.entries(jsonObj)) {
    const sqlKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
    sqlObj[sqlKey] = value;
  }
  return sqlObj;
}

// Convert SQL to JSON (for SELECT operations)
function sqlToJson(sqlObj) {
  const jsonObj = {};
  for (const [key, value] of Object.entries(sqlObj)) {
    const jsonKey = key.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
    jsonObj[jsonKey] = value;
  }
  return jsonObj;
}
```

### API Response Types

The `types/api/` directory contains optimized response types that combine multiple entities:

- **UserDashboardResponse**: Complete user data with workspaces and teams
- **IssueWithDetails**: Full issue data with labels, comments, and relationships
- **ProjectOverview**: Project statistics and team member information
- **WorkspaceAnalytics**: Comprehensive workspace usage metrics
- **CommentWithReactions**: Comments with aggregated reaction data
- **UserWithRoles**: User with complete role assignment details

These types are designed to minimize API calls and provide all necessary data in a single response.

## 🚀 Getting Started

### 1. Create Database
```bash
createdb issue_tracker
```

### 2. Run Schema Setup
```bash
# Run all schema files in order
psql -U postgres -d issue_tracker -f db/setup.sql
```

This will create:
- All tables with proper constraints
- Performance optimization indexes
- Automatic timestamp triggers
- Milestone statistics view
- Initial seed data (reactions)

### 3. Security Configuration

**Important**: The RLS (Row Level Security) system requires your application to set the current user context:

```javascript
// Before each database operation
await db.query("SET app.current_user = $1", [currentUserId]);
```

### 4. Load Test Data (Optional)

Use the JSON files in `data/` directory with the field mapping functions to import test data. See `doc/types-db/analyses/05-field-mapping-guide.md` for complete mapping reference.

### 5. TypeScript Integration
```typescript
import { Issue, User, Project, Status, Priority } from './types';
```

### 6. Using Pre-Built Queries
```javascript
// Example: Get user with memberships
const user = await db.query(userQueries.getUserById, [userId]);
const workspaces = await db.query(userQueries.getUserWorkspaces, [userId]);
```

## 📋 Development Guidelines

### Adding New Entities
1. Create TypeScript interface in `types/entities/`
2. Create SQL schema in `db/schema/`
3. Add to exports in `types/index.ts`
4. Create queries in `db/queries/`
5. Add test data in `data/`

### Modifying Existing Schema
1. Update both TypeScript and SQL definitions
2. Update any affected API response types
3. Add or modify queries as needed
4. Update test data to match
5. Update the milestone stats view if adding new statuses

### Best Practices
- Always use parameterized queries ($1, $2, etc.)
- Include proper indexes for foreign keys
- Add CHECK constraints for enums
- Use triggers for automatic timestamp updates
- Document complex relationships

## 📊 Data Files

The `/data/` directory contains 21 JSON files with realistic, interconnected test data:
- Sample workspaces, users, and teams
- Projects with different statuses and priorities
- Complex issue hierarchies with parent-child relationships
- Threaded comments with reactions
- Complete relationship data for all junction tables

## 🔒 Security Features

- **Row Level Security (RLS)**: Automatic data isolation between workspaces
- **Multi-tenant Architecture**: Complete workspace isolation at database level
- **Advanced Role System**: JSONB permissions with workspace-specific roles
- **Workspace Membership Verification**: All queries verify user access
- **Team Membership Checks**: Team-specific resources properly protected

## 🎯 Architecture Decisions

- **Separate Repository**: Keeps database structure private from public application code
- **UUID Primary Keys**: Better for distributed systems (except User.id for OAuth)
- **JSONB Permissions**: Flexible role-based access control
- **Bidirectional Relations**: Automatic two-way issue relationships via triggers
- **Workspace Isolation**: Complete multi-tenancy support
- **Event Log Pattern**: User role assignments tracked as events for audit trails

## 📈 Performance Considerations

- Milestone statistics are pre-calculated in a view
- API response types minimize N+1 query problems
- Proper indexes on all frequently queried fields
- Efficient relationship queries in `db/queries/`
- Strategic use of composite indexes for complex queries

## ✅ Repository Status

**Production Ready**
- 100% consistency between TypeScript types and SQL schema
- All constraints properly enforced
- Comprehensive test data available
- Complete query coverage for CRUD operations
- Full documentation and field mapping guides

---

*Last updated: July 2025*