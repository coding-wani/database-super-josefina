CREATE TABLE IF NOT EXISTS comment_reactions (
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    reaction_id UUID REFERENCES reactions(id) ON DELETE CASCADE,
    reacted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, comment_id, reaction_id)
);