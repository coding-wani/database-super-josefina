CREATE TABLE IF NOT EXISTS reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),  -- Changed to UUID
    emoji VARCHAR(10) NOT NULL,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_reactions_updated_at BEFORE UPDATE
    ON reactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();