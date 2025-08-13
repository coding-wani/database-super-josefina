// =====================================================
// types/enums/issueState.ts
// PURPOSE: Issue visibility states
// DATABASE: CHECK constraint on issues.issue_state
// 
// STATE BEHAVIOR:
// - draft: Not visible to team, being created
//          Multiple drafts can have publicId="DRAFT"
// - published: Visible to team, has unique ISSUE-XX ID
// 
// TRANSITION:
// draft → published: Publishes issue, assigns sequential ID
// published → draft: Rare, hides from team (like unpublishing)
// =====================================================

export type IssueState = "draft" | "published";