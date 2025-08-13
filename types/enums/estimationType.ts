// =====================================================
// types/enums/estimationType.ts
// PURPOSE: Story point estimation scales for teams
// DATABASE: CHECK constraint on teams.estimation_type
// 
// SCALE TYPES:
// - exponential: 1, 2, 4, 8, 16, 32 (powers of 2)
// - fibonacci: 1, 2, 3, 5, 8, 13, 21 (Fibonacci sequence)
// - linear: 1, 2, 3, 4, 5, 6 (simple counting)
// - tshirt: XS, S, M, L, XL, XXL (size-based)
// - bouldering: V0-V16 (rock climbing difficulty grades)
// 
// USAGE:
// - Set at team level (teams.with_estimation = true)
// - Issues in that team use 1-6 values
// - Frontend maps values to display format
// =====================================================

export type EstimationType = 
  | "exponential" 
  | "fibonacci" 
  | "linear" 
  | "tshirt" 
  | "bouldering";