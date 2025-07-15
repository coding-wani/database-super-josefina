CREATE TABLE IF NOT EXISTS reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- Changed to UUID
    emoji VARCHAR(10) NOT NULL,
    name VARCHAR(100) NOT NULL UNIQUE
);