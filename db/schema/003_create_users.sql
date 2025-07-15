CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(50) PRIMARY KEY,  -- Kept as VARCHAR(50) for OAuth compatibility
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    avatar VARCHAR(500),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_online BOOLEAN DEFAULT false,
    current_workspace_id UUID REFERENCES workspaces(id),
    roles TEXT[] DEFAULT '{}',  -- Array of role names/IDs
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_users_updated_at BEFORE UPDATE
    ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();