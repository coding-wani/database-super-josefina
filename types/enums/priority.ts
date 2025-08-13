// =====================================================
// types/enums/priority.ts
// PURPOSE: Issue priority levels
// DATABASE: CHECK constraint on issues.priority
// 
// USAGE GUIDELINES:
// - no-priority: Default, unassessed items
// - low: Nice to have, can wait
// - medium: Should be done soon
// - high: Important, prioritize
// - urgent: Critical, drop everything
// =====================================================

export type Priority = "no-priority" | "urgent" | "high" | "medium" | "low";