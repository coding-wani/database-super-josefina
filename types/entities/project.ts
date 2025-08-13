// =====================================================
// types/entities/project.ts
// PURPOSE: Container for organizing related work
// DATABASE TABLE: projects
// 
// FEATURES:
// - Can be workspace-wide or team-specific
// - Contains milestones for major deliverables
// - Tracks timeline and progress
// =====================================================

import { ProjectStatus } from "../enums/projectStatus";
import { Priority } from "../enums/priority";
import { Milestone } from "./milestone";

export interface Project {
  // ===== IDENTIFIERS =====
  id: string;              // UUID (internal)
  publicId: string;        // User-facing ID (e.g., "PROJ-001")
  
  // ===== RELATIONSHIPS =====
  workspaceId: string;     // Parent workspace (required)
  teamId?: string;         // Optional team association
                          // NULL = workspace-level project
  
  // ===== DISPLAY FIELDS =====
  name: string;            // Project name
  icon?: string;           // Emoji (🌐) or image URL
  description?: string;    // Project details (Markdown)
  
  // ===== STATUS & PRIORITY =====
  status: ProjectStatus;   // planned, started, paused, completed, canceled
  priority: Priority;      // no-priority, low, medium, high, urgent
  
  // ===== MANAGEMENT =====
  leadId?: string;         // User ID of project manager
  
  // ===== TIMELINE =====
  startDate?: Date;        // Project start
  targetDate?: Date;       // Expected completion
  
  // ===== MILESTONE GENERATION =====
  // Auto-increments for milestone public IDs (MILE-01, MILE-02...)
  nextMilestoneNumber: number;
  
  // ===== RELATED DATA =====
  // Populated via JOINs, not stored in table
  milestones?: Milestone[]; // Project milestones
  
  // ===== TIMESTAMPS =====
  createdAt: Date;
  updatedAt: Date;
}