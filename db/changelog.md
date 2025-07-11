# Database Schema - Issue Tracking System

## Overview

Created a comprehensive PostgreSQL database schema for an App focusing on the issue tracking functionality. The schema supports hierarchical issues, comments with replies, user interactions (reactions, subscriptions, favorites), labeling system, external links, and related issues.

## Understanding Database Concepts

### What is a Junction Table?

A junction table (also called a "join table" or "bridge table") is used when you have a many-to-many relationship. For example:

- One issue can have multiple labels (Bug, Feature, High Priority)
- One label can be used on multiple issues

Instead of trying to store an array of labels inside the issue (which would be inefficient), we create a separate table that just stores pairs of issue IDs and label IDs.

### What is an Index?

Think of an index like a book's index - it helps you find information quickly. Without an index, the database has to scan every single row to find what you're looking for. With an index, it can jump directly to the right location. We create indexes on:

- Foreign keys (for fast joins between tables)
- Columns we filter by often (like status, priority)
- Columns we sort by (like created_at)

### What is a Constraint?

Constraints are rules that ensure data integrity. They prevent bad data from entering the database:

- CHECK constraints: Ensure values meet certain criteria (e.g., priority must be one of: 'urgent', 'high', 'medium', 'low', 'no-priority')
- FOREIGN KEY constraints: Ensure relationships are valid (e.g., assignee_id must reference a real user)
- UNIQUE constraints: Prevent duplicates (e.g., no two users can have the same email)

## Database Structure

### Core Tables

#### 1. **users**

- **Purpose**: Stores all application users
- **Key Fields**:
  - `id`: Unique identifier (string for OAuth compatibility)
  - `username`: Unique login name
  - `email`: Unique email address
  - `avatar`: URL to profile picture
  - `roles[]`: Array of user permissions (PostgreSQL array type)
- **Why it matters for frontend**: When you display a user's name or avatar anywhere in the app, this is where that data comes from

#### 2. **issues**

- **Purpose**: Central table for all issues and sub-issues
- **Key Fields**:
  - `id`: Internal UUID (never shown to users)
  - `public_id`: What users see (e.g., "ISSUE-04")
  - `parent_issue_id`: Links to parent issue (for sub-issues)
  - `parent_comment_id`: Links to comment (if issue was created from a comment)
- **Smart Design Choices**:
  - Uses UUID for `id` to prevent conflicts in distributed systems
  - Separate `public_id` for user-friendly display
  - Self-referencing for unlimited nesting of sub-issues
- **Frontend Impact**: When building the issue hierarchy tree, you'll use `parent_issue_id` to nest issues properly

#### 3. **comments**

- **Purpose**: Comments on issues with support for threaded replies
- **Key Fields**:
  - `parent_issue_id`: Which issue this comment belongs to
  - `parent_comment_id`: Which comment this is replying to (if any)
  - `thread_open`: Can others still reply to this thread?
- **Frontend Usage**: To build a comment thread, recursively render comments based on `parent_comment_id`

#### 4. **issue_labels**

- **Purpose**: Predefined labels that can be attached to issues
- **Constraint Example**: `color VARCHAR(7) NOT NULL CHECK (color ~ '^#[0-9A-Fa-f]{6}$')`
  - This ensures colors are always valid hex codes like #FF5733
- **Frontend Benefit**: You can trust that label colors will always be valid CSS values

#### 5. **reactions**

- **Purpose**: Emoji reactions available for comments
- **Pre-seeded Data**: 12 common reactions (👍, ❤️, 🚀, etc.)
- **Frontend Usage**: Loop through available reactions to show reaction picker

#### 6. **links**

- **Purpose**: External links attached to issues for documentation/reference
- **Cascade Delete**: When an issue is deleted, all its links are automatically deleted too
- **Frontend Display**: Show these as a list of external resources on the issue page

### Junction Tables (Many-to-Many Relationships)

#### 7. **issue_label_relations**

```sql
CREATE TABLE issue_label_relations (
    issue_id UUID REFERENCES issues(id) ON DELETE CASCADE,
    label_id VARCHAR(50) REFERENCES issue_labels(id) ON DELETE CASCADE,
    PRIMARY KEY (issue_id, label_id)
);

Why a junction table?: One issue can have many labels, and one label can be on many issues
How it works: Each row represents one issue-label connection
Example data:
issue_id                              | label_id
---------------------------------------|----------
550e8400-e29b-41d4-a716-446655440001 | label-1 (Bug)
550e8400-e29b-41d4-a716-446655440001 | label-2 (Feature)

Frontend Query: To get all labels for an issue, join this table with issue_labels

8. issue_subscriptions

Purpose: Track who wants notifications for which issues
Key Feature: Stores subscribed_at timestamp
Frontend Use Case: Show "🔔 Subscribed" button and list of subscribers

9. comment_subscriptions

Purpose: Track who wants notifications for comment threads
Smart Design: Separate from issue subscriptions - you might want updates on a specific discussion without following the entire issue

10. issue_favorites

Purpose: Users' starred/favorited issues
Extra Index: On favorited_at DESC for "recently favorited" queries
Frontend Features:

Show star icon filled/unfilled
Build "My Favorites" page sorted by most recent



11. comment_reactions
sqlCREATE TABLE comment_reactions (
    user_id VARCHAR(50),
    comment_id VARCHAR(50),
    reaction_id VARCHAR(50),
    PRIMARY KEY (user_id, comment_id, reaction_id)
);

Three-way relationship: Links users, comments, and reactions
Prevents duplicates: The composite primary key ensures a user can't add the same reaction twice
Allows multiple reactions: A user can add both 👍 and ❤️ to the same comment
Frontend Display: Group by reaction type and show user avatars

12. comment_issues

Purpose: Track when issues are created from comments
Special Field: is_sub_issue boolean - was it created as a sub-issue of the current issue?
Use Case: "Create issue from comment" and "Create sub-issue from comment" features

13. issue_related_issues

Purpose: Link related issues (different from parent-child relationship)
Bidirectional Storage: If A relates to B, we store both A→B and B→A
Why?: Makes queries much faster - finding related issues is a simple lookup
Automatic Management: PostgreSQL trigger maintains both directions:

sql-- When you insert A→B, this trigger automatically inserts B→A
CREATE TRIGGER maintain_bidirectional_relations
AFTER INSERT OR DELETE ON issue_related_issues
FOR EACH ROW
EXECUTE FUNCTION maintain_issue_relations();
PostgreSQL-Specific Optimizations Explained
1. Automatic Timestamp Updates
Every table has created_at and updated_at. PostgreSQL automatically updates these:
sqlCREATE TRIGGER update_issues_updated_at
BEFORE UPDATE ON issues
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
What this means: You never need to manually set updated_at in your frontend code - the database handles it!
2. Cascading Deletes
sqlFOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE
What happens: When you delete an issue, all its comments, reactions, subscriptions, etc. are automatically deleted
Frontend benefit: No need for complex cleanup code - one delete handles everything
3. Check Constraints
sqlCONSTRAINT valid_priority CHECK (priority IN ('no-priority', 'urgent', 'high', 'medium', 'low'))
Protection: Even if your frontend has a bug, the database won't accept invalid values
Developer confidence: You can trust that data in the database is always valid
4. Smart Indexing Strategy
We've created indexes for every common query pattern:

Foreign Key Indexes: Every foreign key has an index
sqlCREATE INDEX idx_issues_creator ON issues(creator_id);
Makes queries like "find all issues created by user X" lightning fast
Multi-column Indexes on Junction Tables:
sqlCREATE INDEX idx_issue_label_relations_issue ON issue_label_relations(issue_id);
CREATE INDEX idx_issue_label_relations_label ON issue_label_relations(label_id);
Optimizes both "labels for an issue" and "issues with a label" queries
Sort Indexes:
sqlCREATE INDEX idx_issues_created_at ON issues(created_at DESC);
The DESC means it's optimized for "newest first" queries

Common Query Patterns (For Frontend Developers)
Get an issue with all its relationships
sql-- This would be done by your backend API, but here's what happens:
SELECT
    i.*,
    creator.username as creator_name,
    assignee.username as assignee_name,
    ARRAY_AGG(DISTINCT l.*) as labels,
    COUNT(DISTINCT s.user_id) as subscriber_count
FROM issues i
LEFT JOIN users creator ON i.creator_id = creator.id
LEFT JOIN users assignee ON i.assignee_id = assignee.id
LEFT JOIN issue_label_relations ilr ON i.id = ilr.issue_id
LEFT JOIN issue_labels l ON ilr.label_id = l.id
LEFT JOIN issue_subscriptions s ON i.id = s.issue_id
WHERE i.id = ?
GROUP BY i.id, creator.username, assignee.username;
Get all reactions for a comment with user info
sqlSELECT
    r.emoji,
    r.name,
    COUNT(*) as count,
    ARRAY_AGG(u.username) as users
FROM comment_reactions cr
JOIN reactions r ON cr.reaction_id = r.id
JOIN users u ON cr.user_id = u.id
WHERE cr.comment_id = ?
GROUP BY r.id, r.emoji, r.name;
Data Flow Examples
Creating a Sub-Issue from a Comment

User clicks "Create sub-issue from comment" on comment-1
Frontend sends request with:

New issue data
parent_issue_id: The current issue's ID
parent_comment_id: 'comment-1'


Backend inserts into issues table
Backend inserts into comment_issues with is_sub_issue: true
Issue now appears as both:

A sub-issue under the parent issue
A linked issue from the comment



Adding a Reaction

User clicks 👍 on a comment
Frontend sends: {user_id, comment_id, reaction_id}
Database tries to insert into comment_reactions
If already exists (duplicate primary key), nothing happens
Frontend re-fetches reactions and updates count

Why This Design Scales

Normalized Structure: No duplicate data means less storage and easier updates
Efficient Indexes: Every common query has an optimized path
PostgreSQL Arrays: For small lists (like roles), arrays are more efficient than junction tables
UUID Primary Keys: No conflicts when merging data from multiple sources
Bidirectional Relations: Trades small storage increase for massive query performance gain

Migration Safety
All our SQL files use safe patterns:

CREATE TABLE IF NOT EXISTS: Won't error if table already exists
ON CONFLICT DO NOTHING: Prevents duplicate key errors
Numbered files (001_, 002_): Ensures correct execution order
Deferred constraints: Handles circular references properly

For Frontend Developers: What This Means for You

Trust the Data: Constraints ensure you'll never get invalid data
Relationships are Handled: Cascading deletes mean less cleanup code
Performance is Built-in: Indexes mean your queries will be fast
Timestamps are Automatic: Just display them, don't worry about updating
Flexible Queries: The junction tables let you query relationships from any direction

Future Extensibility
The schema is designed to grow:

Custom Fields: Can add JSONB columns for flexible data
Audit Trail: Timestamp triggers ready for history tracking
Performance: Indexes can be added without changing structure
New Features: Junction table pattern makes new relationships easy


This version:
1. Explains every database concept in simple terms
2. Shows concrete examples of how junction tables work
3. Explains what indexes do and why they matter
4. Includes code examples with explanations
5. Connects database design to frontend concerns
6. Is much more comprehensive than the original
```
