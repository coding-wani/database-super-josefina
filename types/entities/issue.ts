// =====================================================
// types/entities/issue.ts
// PURPOSE: Core work item entity (tickets/tasks/bugs)
// DATABASE TABLE: issues
// 
// KEY CONCEPTS:
// - Two states: draft (being created) and published (visible)
// - Draft issues share publicId = "DRAFT"
// - Published issues get unique ISSUE-XX IDs
// - Supports hierarchy via parent_issue_id
// =====================================================

import { Priority } from "../enums/priority";
import { Status } from "../enums/status";
import { IssueState } from "../enums/issueState";
import { IssueLabel } from "./issueLabel";
import { User } from "./user";
import { Link } from "./link";

export interface Issue {
  // ===== IDENTIFIERS =====
  id: string;              // PostgreSQL UUID (internal, always unique)
  
  /**
   * User-facing ID for the issue.
   * 
   * BEHAVIOR:
   * - Draft issues: Always "DRAFT" (multiple drafts can share this)
   * - Published issues: Sequential "ISSUE-01", "ISSUE-02", etc.
   * 
   * IMPORTANT: "DRAFT" is just a placeholder. Draft issues are
   * identified by their UUID internally. The publicId becomes unique
   * only after publishing when it receives a sequential number.
   * 
   * WORKFLOW:
   * 1. Create issue → publicId = "DRAFT", issueState = "draft"
   * 2. Publish issue → publicId = "ISSUE-XX", issueState = "published"
   */
  publicId: string;
  
  // ===== MULTI-TENANCY =====
  workspaceId: string;     // Required for RLS (Row-Level Security)
  teamId?: string;         // Optional - NULL for workspace/project-level
                          // If set, only team members can see issue
  
  // ===== PROJECT ASSOCIATION =====
  projectId?: string;      // Optional project association
  milestoneId?: string;    // Optional milestone (requires projectId)
  
  // ===== ISSUE METADATA =====
  priority: Priority;      // no-priority, low, medium, high, urgent
  status: Status;          // triage, backlog, todo, in-progress, done...
  issueState: IssueState;  // draft or published
  
  // ===== CONTENT =====
  title: string;           // Issue title (required)
  description?: string;    // Markdown content (optional)
  
  // ===== PEOPLE =====
  creatorId: string;       // User who created (VARCHAR(50))
  assigneeId?: string;     // User assigned to work on it
  
  // ===== HIERARCHY =====
  parentIssueId?: string;  // UUID of parent (for sub-issues)
                          // Sub-issues inherit team from parent
  
  // ===== RELATIONSHIPS (via JOINs) =====
  // These are populated from junction tables, not stored directly
  labels?: IssueLabel[];   // From issue_label_relations
  subscribers?: User[];    // From issue_subscriptions
  favoritedBy?: User[];    // From issue_favorites
  links?: Link[];          // From links table
  relatedIssues?: Issue[]; // From issue_related_issues (bidirectional)
  
  // ===== PLANNING =====
  dueDate?: Date;          // Optional deadline
  
  // Only for teams with estimation enabled
  // Simplified Fibonacci: 1, 2, 3, 5, 8, 13 → we use 1-6
  estimation?: number;     // Story points (1-6)
  
  // ===== TIMESTAMPS =====
  createdAt: Date;
  updatedAt: Date;
}