-- =====================================================
-- 009_seed_milestones.sql
-- TYPE: Organization Structure / Core Entity
-- PURPOSE: Define project checkpoints and deliverables
-- DEPENDENCIES:
--   - 008_seed_projects.sql (milestones belong to projects)
-- CREATES: 3 milestones across 2 projects
-- 
-- MILESTONES:
-- - Website Redesign: Alpha Release (MILE-01), Beta Release (MILE-02)
-- - Q1 Planning: Planning Complete (MILE-01)
-- 
-- NOTES:
-- - Public IDs are unique per project (both have MILE-01)
-- - Milestones track issue progress via milestone_stats view
-- - Cannot exist without a parent project
-- =====================================================

-- Seed milestones
INSERT INTO milestones (id, public_id, project_id, title, description, icon, created_at, updated_at) VALUES
    ('550e8400-e29b-41d4-a716-446655440500', 'MILE-01', '22222222-2222-2222-2222-222222222221', 'Alpha Release', 'First internal release with core features', '🎯', '2025-01-01T00:00:00Z', '2025-01-01T00:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440501', 'MILE-02', '22222222-2222-2222-2222-222222222221', 'Beta Release', 'Public beta with expanded feature set', '🚀', '2025-01-15T00:00:00Z', '2025-01-15T00:00:00Z'),
    ('550e8400-e29b-41d4-a716-446655440502', 'MILE-01', '22222222-2222-2222-2222-222222222222', 'Planning Complete', 'All teams have submitted their Q1 objectives', '✅', '2024-12-15T00:00:00Z', '2025-01-15T00:00:00Z')
ON CONFLICT (id) DO NOTHING;