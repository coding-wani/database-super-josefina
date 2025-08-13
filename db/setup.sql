-- =====================================================
-- setup.sql
-- PURPOSE: Master initialization script for the Issue Tracker database
-- EXECUTION: psql -U username -d database -f db/setup.sql
-- 
-- DESCRIPTION:
-- This file orchestrates the complete database setup by running
-- all schema and seed files in the correct dependency order.
-- It creates tables, indexes, views, functions, triggers, and
-- populates initial test data.
-- 
-- IMPORTANT:
-- - Files MUST run in this exact order due to foreign key dependencies
-- - Schema files create structure (tables, constraints, etc.)
-- - Seed files populate test/initial data
-- - Running this on existing database will fail (use migrations instead)
-- 
-- PREREQUISITES:
-- - PostgreSQL 12+ (for gen_random_uuid() function)
-- - Database must exist (CREATE DATABASE your_db_name;)
-- - User must have CREATE privileges
-- - Extensions: None required (gen_random_uuid is built-in)
-- =====================================================

-- =====================================================
-- PHASE 1: SCHEMA CREATION (Structure)
-- Creates all tables, constraints, indexes, and functions
-- Total: 23 schema files
-- =====================================================

-- =====================================================
-- Foundation Tables (Must be first)
-- These have no dependencies or create global functions
-- =====================================================

-- Creates user roles table and inserts 4 system roles
-- Also creates update_updated_at_column() trigger function (used by all tables)
\i schema/001_create_user_roles.sql

-- Creates workspaces table (top-level multi-tenant container)
-- Also creates the GLOBAL update_updated_at_column() function
\i schema/002_create_workspaces.sql

-- Creates users table (VARCHAR(50) ID for OAuth compatibility)
\i schema/003_create_users.sql

-- =====================================================
-- Organization Structure
-- Teams, Projects, and Milestones for work organization
-- =====================================================

-- Creates teams table (with estimation settings)
\i schema/004_create_teams.sql

-- Creates projects table (can be team or workspace level)
\i schema/005_create_projects.sql

-- Creates milestones table (always belong to projects)
\i schema/006_create_milestones.sql

-- =====================================================
-- Core Content Tables
-- Issues and related communication/metadata
-- =====================================================

-- Creates issues table (main work items with draft/published states)
\i schema/007_create_issues.sql

-- Creates comments table (threaded discussions on issues)
\i schema/008_create_comments.sql

-- Creates issue_labels table (categorization system)
\i schema/009_create_issue_labels.sql

-- Creates reactions table (emoji library for comments)
\i schema/010_create_reactions.sql

-- =====================================================
-- Relationship Tables (Junction/Many-to-Many)
-- Link entities together with optional metadata
-- =====================================================

-- Links issues to labels (many-to-many)
\i schema/011_create_issue_label_relations.sql

-- Tracks issue subscriptions for notifications
\i schema/012_create_issue_subscriptions.sql

-- Tracks comment subscriptions (currently unused)
\i schema/013_create_comment_subscriptions.sql

-- Personal issue bookmarking system
\i schema/014_create_issue_favorites.sql

-- Links comments to reactions with users
\i schema/015_create_comment_reactions.sql

-- =====================================================
-- Performance & Extended Features
-- =====================================================

-- Creates 30+ additional indexes for query optimization
\i schema/016_create_indexes.sql

-- External URL attachments for issues
\i schema/017_create_links.sql

-- Bidirectional issue relationships with auto-maintain trigger
\i schema/018_create_issue_related_issues.sql

-- =====================================================
-- Membership Tables
-- User access control and team composition
-- =====================================================

-- User-workspace associations with roles
\i schema/019_create_workspace_memberships.sql

-- User-team associations with roles
\i schema/020_create_team_memberships.sql

-- =====================================================
-- Security & Analytics
-- =====================================================

-- Enables Row-Level Security for multi-tenancy
-- Creates policies for workspace/team data isolation
\i schema/021_enable_rls.sql

-- Creates view for milestone progress statistics
\i schema/022_create_milestone_stats_view.sql

-- Event log table for role assignment audit trail
-- NOT a junction table - tracks complete history
\i schema/023_create_user_role_assignment_events.sql

-- =====================================================
-- PHASE 2: SEED DATA (Initial/Test Data)
-- Populates tables with sample data for development/testing
-- Total: 20 seed files
-- 
-- SEED DATA SUMMARY:
-- - 2 Workspaces (Interesting Workspace, School Manager)
-- - 5 Users with different roles
-- - 3 Teams with different estimation settings
-- - 2 Projects with milestones
-- - 14 Issues (12 published, 2 drafts)
-- - Comments, reactions, labels, subscriptions
-- =====================================================

-- =====================================================
-- Foundation Seeds
-- Core entities that others depend on
-- =====================================================

-- 12 emoji reactions (🥰, 😊, 🤔, etc.)
\i seeds/001_initial_reactions.sql

-- 2 workspaces: IW (Interesting Workspace), SM (School Manager)
\i seeds/002_seed_workspaces.sql

-- 1 custom role (project_manager) for IW workspace
\i seeds/003_seed_user_roles.sql

-- 5 users: John (super_admin), Jane (project_manager), 
-- Alex (support), Gigi (beta_tester), Julian (developer)
\i seeds/004_seed_users.sql

-- =====================================================
-- Membership Seeds
-- Assign users to workspaces and teams
-- =====================================================

-- 6 workspace memberships (who belongs where)
\i seeds/005_seed_workspace_memberships.sql

-- 3 teams: Engineering (fibonacci), Design (no estimation), Teachers (tshirt)
\i seeds/006_seed_teams.sql

-- 5 team memberships (who's on which team)
\i seeds/007_seed_team_memberships.sql

-- =====================================================
-- Project Structure Seeds
-- =====================================================

-- 2 projects: Website Redesign, Q1 Planning
\i seeds/008_seed_projects.sql

-- 3 milestones: Alpha, Beta (Website), Planning Complete (Q1)
\i seeds/009_seed_milestones.sql

-- 4 labels: Bug, Feature, ideation, Issue Tracking Test
\i seeds/010_seed_issue_labels.sql

-- =====================================================
-- Content Seeds
-- Issues and communication
-- =====================================================

-- 14 issues: ISSUE-01 to ISSUE-10 (published), 2 DRAFTs
-- Includes sub-issues and various states/priorities
\i seeds/011_seed_issues.sql

-- 3 comments (including 1 reply thread)
\i seeds/012_seed_comments.sql

-- =====================================================
-- Event & Relationship Seeds
-- =====================================================

-- 5 role assignment events (audit log entries)
\i seeds/013_seed_user_role_assignment_events.sql

-- 6 comment reactions (users reacting to comments)
\i seeds/014_seed_comment_reactions.sql

-- 5 issue-label associations
\i seeds/015_seed_issue_label_relations.sql

-- 5 issue subscriptions (notification preferences)
\i seeds/016_seed_issue_subscriptions.sql

-- 5 issue favorites (bookmarks)
\i seeds/017_seed_issue_favorites.sql

-- 0 comment subscriptions (empty - future feature)
\i seeds/018_seed_comment_subscriptions.sql

-- 3 bidirectional issue relationships (6 total records)
\i seeds/019_seed_issue_related_issues.sql

-- 6 external links attached to issues
\i seeds/020_seed_links.sql

-- =====================================================
-- COMPLETION NOTES
-- =====================================================
-- After running this script:
-- 1. Database is fully initialized with schema and test data
-- 2. RLS is enabled - set app.current_user for queries
-- 3. All triggers and functions are active
-- 4. Ready for application connection
-- 
-- To verify installation:
-- SELECT COUNT(*) FROM users;  -- Should return 5
-- SELECT COUNT(*) FROM issues; -- Should return 14
-- SELECT COUNT(*) FROM teams;  -- Should return 3
-- 
-- To reset database:
-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;
-- Then run this script again
-- =====================================================