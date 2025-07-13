# Database Schema - Issue Tracking System

## Overview

This document describes a comprehensive PostgreSQL database schema for an issue tracking system (Linear clone). The schema supports hierarchical issues, threaded comments, user interactions (reactions, subscriptions, favorites), a flexible labeling system, external links, and bidirectional issue relationships.

## Core Design Principles

1. **UUID for Issues**: Uses PostgreSQL's native UUID type for issue IDs to prevent conflicts in distributed systems
2. **String IDs for External Systems**: Uses VARCHAR(50) for user/comment IDs to support OAuth and external integrations
3. **Junction Tables**: Properly normalized many-to-many relationships
4. **Automatic Timestamps**: PostgreSQL triggers maintain `updated_at` columns
5. **Cascading Deletes**: Referential integrity with automatic cleanup
6. **Comprehensive Indexing**: Every foreign key and commonly queried field is indexed

## Database Tables

### Core Entity Tables

#### 1. **users**
Stores all application users with support for OAuth integration.

```sql
CREATE TABLE users (
    id VARCHAR(50) PRIMARY KEY,           -- Supports OAuth IDs
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    avatar VARCHAR(500),                   -- URL to profile picture
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_online BOOLEAN DEFAULT false,
    roles TEXT[],                          -- PostgreSQL array for multiple roles
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

**Key Features**:
- Uses TEXT[] array for roles (PostgreSQL-specific optimization)
- Automatic timestamp updates via trigger
- Supports nullable email for flexibility

#### 2. **issues**
Central table for all issues and sub-issues with hierarchical support.

```sql
CREATE TABLE issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    public_id VARCHAR(50) UNIQUE NOT NULL,    -- User-facing ID (e.g., "ISSUE-04")
    priority VARCHAR(20) NOT NULL DEFAULT 'no-priority',
    status VARCHAR(20) NOT NULL DEFAULT 'backlog',
    title VARCHAR(255) NOT NULL,
    description TEXT,                          -- Markdown content
    creator_id VARCHAR(50) NOT NULL REFERENCES users(id),
    parent_issue_id UUID REFERENCES issues(id),  -- For sub-issues
    parent_comment_id VARCHAR(50),               -- When created from comment
    due_date TIMESTAMP,
    assignee_id VARCHAR(50) REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Data integrity constraints
    CONSTRAINT valid_priority CHECK (priority IN ('no-priority', 'urgent', 'high', 'medium', 'low')),
    CONSTRAINT valid_status CHECK (status IN ('backlog', 'todo', 'in-progress', 'done', 'canceled', 'duplicate'))
);
```

**Design Decisions**:
- Separate `id` (internal UUID) and `public_id` (user-facing)
- Self-referential `parent_issue_id` enables unlimited sub-issue nesting
- CHECK constraints ensure data validity at the database level

#### 3. **comments**
Supports threaded discussions with nested replies.

```sql
CREATE TABLE comments (
    id VARCHAR(50) PRIMARY KEY,
    author_id VARCHAR(50) NOT NULL REFERENCES users(id),
    description TEXT NOT NULL,                   -- Markdown content
    parent_issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    parent_comment_id VARCHAR(50) REFERENCES comments(id),  -- For replies
    thread_open BOOLEAN DEFAULT true,            -- Can receive new replies?
    comment_url VARCHAR(500),                    -- Deep link to comment
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

**Features**:
- Self-referential design for comment threads
- Cascade delete ensures cleanup when issue is deleted
- `thread_open` allows locking specific discussion threads

#### 4. **issue_labels**
Predefined labels with color validation.

```sql
CREATE TABLE issue_labels (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    color VARCHAR(7) NOT NULL CHECK (color ~ '^#[0-9A-Fa-f]{6}$')  -- Validates hex colors
);
```

**PostgreSQL Feature**: Uses regex CHECK constraint to ensure valid hex colors

#### 5. **reactions**
Available emoji reactions for comments.

```sql
CREATE TABLE reactions (
    id VARCHAR(50) PRIMARY KEY,
    emoji VARCHAR(10) NOT NULL,     -- The actual emoji (e.g., "👍")
    name VARCHAR(100) NOT NULL UNIQUE  -- Identifier (e.g., "thumbs_up")
);
```

Pre-seeded with 12 common reactions via `seeds/001_initial_reactions.sql`

#### 6. **links**
External references attached to issues.

```sql
CREATE TABLE links (
    id VARCHAR(50) PRIMARY KEY,
    issue_id UUID NOT NULL REFERENCES issues(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    url TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

### Junction Tables (Many-to-Many Relationships)

#### 7. **issue_label_relations**
Links issues to their labels.

```sql
CREATE TABLE issue_label_relations (
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    label_id VARCHAR(50) REFERENCES issue_labels(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (issue_id, label_id)
);
```

**Why a junction table?** 
- One issue can have multiple labels (Bug + High Priority + Feature)
- One label can be used on multiple issues
- Composite primary key prevents duplicate assignments

#### 8. **issue_subscriptions**
Tracks which users want notifications for specific issues.

```sql
CREATE TABLE issue_subscriptions (
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    subscribed_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, issue_id)
);
```

#### 9. **comment_subscriptions**
Separate from issue subscriptions - users can follow specific discussion threads.

```sql
CREATE TABLE comment_subscriptions (
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    comment_id VARCHAR(50) REFERENCES comments(id) ON DELETE CASCADE,
    subscribed_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, comment_id)
);
```

#### 10. **issue_favorites**
User's starred/bookmarked issues.

```sql
CREATE TABLE issue_favorites (
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    favorited_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, issue_id)
);
```

#### 11. **comment_reactions**
Three-way relationship linking users, comments, and their reactions.

```sql
CREATE TABLE comment_reactions (
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    comment_id VARCHAR(50) REFERENCES comments(id) ON DELETE CASCADE,
    reaction_id VARCHAR(50) REFERENCES reactions(id) ON DELETE CASCADE,
    reacted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, comment_id, reaction_id)
);
```

**Design Note**: The composite primary key allows a user to add multiple different reactions to the same comment, but prevents duplicate identical reactions.

#### 12. **comment_issues**
Tracks when issues are created from comments.

```sql
CREATE TABLE comment_issues (
    comment_id VARCHAR(50) REFERENCES comments(id) ON DELETE CASCADE,
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    is_sub_issue BOOLEAN DEFAULT false,  -- Was it created as a sub-issue?
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (comment_id, issue_id)
);
```

#### 13. **issue_related_issues**
Bidirectional relationships between issues (different from parent-child).

```sql
CREATE TABLE issue_related_issues (
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    related_issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (issue_id, related_issue_id),
    CONSTRAINT no_self_relation CHECK (issue_id != related_issue_id)
);
```

**Advanced Feature**: Uses PostgreSQL trigger to maintain bidirectional consistency automatically.

## PostgreSQL-Specific Optimizations

### 1. Automatic Timestamp Management
Every table with timestamps uses this trigger pattern:

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_[table_name]_updated_at 
BEFORE UPDATE ON [table_name] 
FOR EACH ROW 
EXECUTE FUNCTION update_updated_at_column();
```

**Benefit**: The `updated_at` column is automatically maintained by the database - no application code needed.

### 2. Bidirectional Relationship Management
For related issues, a trigger maintains both directions:

```sql
CREATE OR REPLACE FUNCTION maintain_issue_relations() 
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- When A→B is inserted, automatically insert B→A
        INSERT INTO issue_related_issues (issue_id, related_issue_id, created_at)
        VALUES (NEW.related_issue_id, NEW.issue_id, NEW.created_at)
        ON CONFLICT DO NOTHING;
    ELSIF TG_OP = 'DELETE' THEN
        -- When A→B is deleted, automatically delete B→A
        DELETE FROM issue_related_issues 
        WHERE issue_id = OLD.related_issue_id 
        AND related_issue_id = OLD.issue_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Benefit**: Ensures data consistency and makes queries faster (no need for OR conditions).

### 3. Comprehensive Indexing Strategy

```sql
-- Foreign key indexes (for JOIN performance)
CREATE INDEX idx_issues_creator ON issues(creator_id);
CREATE INDEX idx_issues_assignee ON issues(assignee_id);
CREATE INDEX idx_comments_author ON comments(author_id);

-- Filter indexes (for WHERE clauses)
CREATE INDEX idx_issues_status ON issues(status);
CREATE INDEX idx_issues_priority ON issues(priority);

-- Sort indexes (for ORDER BY)
CREATE INDEX idx_issues_created_at ON issues(created_at DESC);
CREATE INDEX idx_issue_favorites_date ON issue_favorites(favorited_at DESC);

-- Junction table indexes (both directions)
CREATE INDEX idx_issue_label_relations_issue ON issue_label_relations(issue_id);
CREATE INDEX idx_issue_label_relations_label ON issue_label_relations(label_id);
```

**Index Design Principles**:
- Every foreign key gets an index
- Columns used in WHERE clauses get indexes
- Sort columns get indexes with appropriate direction (DESC for newest-first)
- Junction tables get indexes on both foreign keys

## Query Performance Examples

### Efficient Query: Get issue with all relationships
```sql
-- Leverages multiple indexes for fast execution
SELECT 
    i.*,
    creator.username as creator_name,
    array_agg(DISTINCT l.name) as label_names,
    count(DISTINCT s.user_id) as subscriber_count,
    count(DISTINCT f.user_id) as favorite_count
FROM issues i
JOIN users creator ON i.creator_id = creator.id              -- Uses idx_issues_creator
LEFT JOIN issue_label_relations ilr ON i.id = ilr.issue_id   -- Uses idx_issue_label_relations_issue
LEFT JOIN issue_labels l ON ilr.label_id = l.id
LEFT JOIN issue_subscriptions s ON i.id = s.issue_id         -- Uses idx_issue_subscriptions_issue
LEFT JOIN issue_favorites f ON i.id = f.issue_id             -- Uses idx_issue_favorites_issue
WHERE i.status = 'in-progress'                                -- Uses idx_issues_status
GROUP BY i.id, creator.username
ORDER BY i.created_at DESC;                                   -- Uses idx_issues_created_at
```

### Efficient Query: Get comment reactions grouped
```sql
-- Optimized for reaction display
SELECT 
    r.emoji,
    r.name,
    count(*) as reaction_count,
    array_agg(u.username ORDER BY cr.reacted_at) as users
FROM comment_reactions cr
JOIN reactions r ON cr.reaction_id = r.id
JOIN users u ON cr.user_id = u.id
WHERE cr.comment_id = ?                                       -- Uses idx_comment_reactions_comment
GROUP BY r.id, r.emoji, r.name
ORDER BY reaction_count DESC;
```

## Data Integrity Features

1. **Cascading Deletes**: When a parent entity is deleted, all related records are automatically removed
2. **Check Constraints**: Invalid enum values are rejected at the database level
3. **Unique Constraints**: Prevents duplicate usernames, emails, and public IDs
4. **Foreign Key Constraints**: Ensures all relationships reference valid records
5. **Composite Primary Keys**: Prevents duplicate entries in junction tables

## Migration Safety

The schema uses safe migration patterns:

```sql
CREATE TABLE IF NOT EXISTS ...           -- Won't error if table exists
ON CONFLICT DO NOTHING                   -- Prevents duplicate key errors in seeds
ALTER TABLE ... ADD CONSTRAINT IF NOT EXISTS  -- Safe constraint additions
```

## Summary

This schema provides:
- **Flexibility**: Hierarchical issues, threaded comments, multiple relationship types
- **Performance**: Strategic indexes on all foreign keys and commonly queried fields
- **Data Integrity**: Constraints, triggers, and cascading deletes ensure consistency
- **PostgreSQL Optimization**: Uses arrays, triggers, and CHECK constraints effectively
- **Scalability**: UUID primary keys, efficient junction tables, and optimized queries

The design balances normalization (for data integrity) with strategic denormalization (PostgreSQL arrays for roles) and includes PostgreSQL-specific features that reduce application complexity while improving performance.