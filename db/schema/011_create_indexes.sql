-- Issues indexes
CREATE INDEX IF NOT EXISTS idx_issues_creator ON issues(creator_id);
CREATE INDEX IF NOT EXISTS idx_issues_assignee ON issues(assignee_id);
CREATE INDEX IF NOT EXISTS idx_issues_parent_issue ON issues(parent_issue_id);
CREATE INDEX IF NOT EXISTS idx_issues_parent_comment ON issues(parent_comment_id);
CREATE INDEX IF NOT EXISTS idx_issues_status ON issues(status);
CREATE INDEX IF NOT EXISTS idx_issues_priority ON issues(priority);
CREATE INDEX IF NOT EXISTS idx_issues_created_at ON issues(created_at DESC);

-- Comments indexes
CREATE INDEX IF NOT EXISTS idx_comments_author ON comments(author_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent_issue ON comments(parent_issue_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent_comment ON comments(parent_comment_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at DESC);

-- Issue subscriptions indexes
CREATE INDEX IF NOT EXISTS idx_issue_subscriptions_issue ON issue_subscriptions(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_subscriptions_user ON issue_subscriptions(user_id);

-- Comment subscriptions indexes
CREATE INDEX IF NOT EXISTS idx_comment_subscriptions_comment ON comment_subscriptions(comment_id);
CREATE INDEX IF NOT EXISTS idx_comment_subscriptions_user ON comment_subscriptions(user_id);

-- Issue favorites indexes
CREATE INDEX IF NOT EXISTS idx_issue_favorites_issue ON issue_favorites(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_favorites_user ON issue_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_issue_favorites_date ON issue_favorites(favorited_at DESC);

-- Comment reactions indexes
CREATE INDEX IF NOT EXISTS idx_comment_reactions_comment ON comment_reactions(comment_id);
CREATE INDEX IF NOT EXISTS idx_comment_reactions_user ON comment_reactions(user_id);
CREATE INDEX IF NOT EXISTS idx_comment_reactions_reaction ON comment_reactions(reaction_id);

-- Issue label relations indexes
CREATE INDEX IF NOT EXISTS idx_issue_label_relations_issue ON issue_label_relations(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_label_relations_label ON issue_label_relations(label_id);