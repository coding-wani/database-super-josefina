CREATE TABLE IF NOT EXISTS comment_subscriptions (
    user_id VARCHAR(50) REFERENCES users(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    subscribed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, comment_id)
);