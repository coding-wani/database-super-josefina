# Database Schema for Linear Clone - Issue Tracking System

## Overview

Created a comprehensive PostgreSQL database schema for a Linear.app clone focusing on the issue tracking functionality. The schema supports hierarchical issues, comments with replies, user interactions (reactions, subscriptions, favorites), labeling system, external links, and related issues.

## Database Structure

### Core Tables

#### 1. **users**

- Stores all application users
- Fields: id, username, email, avatar, first_name, last_name, is_online, roles[], created_at, updated_at
- Used by: issue creators, assignees, comment authors, subscribers, etc.

#### 2. **issues**

- Central table for all issues and sub-issues
- Fields: id (UUID), public_id (e.g., "ISSUE-04"), priority, status, title, description (markdown), creator_id, parent_issue_id, parent_comment_id, due_date, assignee_id, created_at, updated_at
- Supports:
  - Hierarchical structure (issues can have sub-issues via parent_issue_id)
  - Issues created from comments (via parent_comment_id)
  - Priority levels: no-priority, urgent, high, medium, low
  - Status: backlog, todo, in-progress, done, canceled, duplicate

#### 3. **comments**

- Comments on issues with support for threaded replies
- Fields: id, author_id, description (markdown), parent_issue_id, parent_comment_id, thread_open, comment_url, created_at, updated_at
- Features:
  - Nested comments (replies) via parent_comment_id
  - Thread locking (thread_open boolean)
  - Direct linking via comment_url

#### 4. **issue_labels**

- Predefined labels that can be attached to issues
- Fields: id, name, color (hex)

#### 5. **reactions**

- Emoji reactions available for comments
- Fields: id, emoji (actual emoji), name (code like "heart_eyes")
- Seeded with 12 common reactions

#### 6. **links**

- External links attached to issues for documentation/reference
- Fields: id, issue_id, title, url, created_at, updated_at
- Each issue can have multiple links

### Junction Tables (Many-to-Many Relationships)

#### 7. **issue_label_relations**

- Links issues to multiple labels
- Fields: issue_id, label_id, created_at

#### 8. **issue_subscriptions**

- Users subscribed to issue notifications
- Fields: user_id, issue_id, subscribed_at

#### 9. **comment_subscriptions**

- Users subscribed to comment thread notifications
- Fields: user_id, comment_id, subscribed_at

#### 10. **issue_favorites**

- Users' favorited issues
- Fields: user_id, issue_id, favorited_at

#### 11. **comment_reactions**

- Tracks which users added which reactions to comments
- Fields: user_id, comment_id, reaction_id, reacted_at

#### 12. **comment_issues**

- Tracks issues created from comments
- Fields: comment_id, issue_id, is_sub_issue, created_at

#### 13. **issue_related_issues**

- Bidirectional relationships between related issues
- Fields: issue_id, related_issue_id, created_at
- Constraint prevents self-relations

### Key Features Implemented

1. **Hierarchical Issues**: Issues can have unlimited sub-issues
2. **Related Issues**: Issues can be linked to other related issues (different from parent-child)
3. **External Links**: Issues can have multiple reference links with titles
4. **Comment Threading**: Comments support nested replies
5. **Flexible Origin**: Issues can be created standalone, as sub-issues, or from comments
6. **Rich Interactions**: Users can subscribe, favorite, and react to content
7. **Markdown Support**: Descriptions and comments support full markdown
8. **Audit Trail**: All tables include created_at and updated_at with automatic triggers

### Indexing Strategy

- Foreign key indexes on all relationship fields
- Status and priority indexes for filtering
- Date indexes for sorting (created_at DESC)
- Composite indexes on junction tables for bidirectional queries

### TypeScript Models

Created corresponding TypeScript interfaces for type-safe development:

- User, Issue, Comment, IssueLabel, Reaction, Link
- Type unions for Priority and Status
- Proper nullable fields and optional arrays

### Mock Data

Generated realistic mock data covering:

- 5 users with different roles
- 12 issues including sub-issues and comment-originated issues
- Comments with replies
- 6 external links across various issues
- Related issue connections
- Full relationship data for subscriptions, favorites, labels, and reactions

## Usage Notes

1. **Circular Dependency**: Issues and Comments have a circular reference. The schema handles this by adding the foreign key constraint after both tables are created.

2. **ID Strategy**:

   - Users use string IDs (for potential OAuth integration)
   - Issues use UUIDs with separate public_id for user-facing display
   - Comments, Links, and other tables use string IDs

3. **Related Issues**: The relationship is bidirectional and stored twice in the junction table for easier querying from either direction.

4. **Performance**: Comprehensive indexing ensures efficient queries for:

   - Finding all subscribers to an issue/comment
   - Listing user's subscriptions/favorites
   - Filtering by status/priority
   - Chronological sorting
   - Related issue navigation

5. **Future Considerations**: The schema is extensible for features like:
   - Issue templates
   - Custom fields
   - Time tracking
   - Sprint/milestone associations
   - Link previews/metadata
