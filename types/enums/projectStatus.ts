// =====================================================
// types/enums/projectStatus.ts
// PURPOSE: Project lifecycle states
// DATABASE: CHECK constraint on projects.status
// 
// STATUS FLOW:
// planned → started → completed (success path)
//        ↘         ↗
//          paused
//        ↘
//          canceled
// 
// DESCRIPTIONS:
// - planned: Not yet started, in planning
// - started: Active development
// - paused: Temporarily on hold
// - completed: Successfully finished
// - canceled: Abandoned, won't complete
// =====================================================

export type ProjectStatus =
  | "planned"
  | "started"
  | "paused"
  | "completed"
  | "canceled";