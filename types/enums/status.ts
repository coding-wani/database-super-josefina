// =====================================================
// types/enums/status.ts
// PURPOSE: Issue workflow states
// DATABASE: CHECK constraint on issues.status
// 
// WORKFLOW STAGES:
// 1. INTAKE: triage → backlog
// 2. PLANNING: todo → planning
// 3. EXECUTION: in-progress → in-review
// 4. COMPLETION: done → commit
// 5. CANCELED: canceled, decline, duplicate
// 
// STATE DESCRIPTIONS:
// - triage: New, needs assessment
// - backlog: Accepted, queued for work
// - todo: Ready to start, prioritized
// - planning: Being designed/specified
// - in-progress: Active development
// - in-review: Code review, testing
// - done: Work complete
// - commit: Merged/deployed to production
// - canceled: Won't do, abandoned
// - decline: Rejected, won't implement
// - duplicate: Already exists elsewhere
// =====================================================

export type Status =
  | "triage"
  | "backlog"
  | "todo"
  | "planning"
  | "in-progress"
  | "in-review"
  | "done"
  | "commit"
  | "canceled"
  | "decline"
  | "duplicate";
