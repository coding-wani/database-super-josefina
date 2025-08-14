// =====================================================
// types/api/issueWithDetails.ts
// PURPOSE: API response type for detailed issue view(NB:1)
// SOURCE TABLES: issues + users + issue_labels + comments + links + relationships
// 
// KEY CONCEPTS:
// - Complete issue data with all relationships
// - Used for issue detail pages/modals
// - Pre-loads related entities to reduce API calls
// - Includes hierarchical issue relationships
//
// NB:
// (1) API RESPONSE TYPE (Composed Data)
// This type combines multiple database entities and
// relationships for comprehensive issue display
// =====================================================

import { Issue } from "../entities/issue";
import { User } from "../entities/user";
import { IssueLabel } from "../entities/issueLabel";
import { Comment } from "../entities/comment";
import { Link } from "../entities/link";

export interface IssueWithDetails {
  // ===== CORE ISSUE DATA =====
  issue: Issue;                // The main issue entity
  
  // ===== USER RELATIONSHIPS =====
  creator: User;               // User who created the issue
  assignee?: User;             // User assigned to the issue
  subscribers: User[];         // Users following this issue
  
  // ===== CATEGORIZATION =====
  labels: IssueLabel[];        // Labels applied to this issue
  
  // ===== DISCUSSION =====
  comments: Comment[];         // All comments on this issue
  
  // ===== ATTACHMENTS =====
  links: Link[];               // Links/attachments to this issue
  
  // ===== ISSUE HIERARCHY =====
  parentIssue?: Issue;         // Parent issue if this is a sub-issue
  subIssues?: Issue[];         // Child issues under this one
  relatedIssues?: Issue[];     // Related/linked issues
}
