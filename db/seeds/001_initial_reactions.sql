INSERT INTO reactions (emoji, name, created_at, updated_at) VALUES
    ('🥰', 'heart_eyes', NOW(), NOW()),
    ('😊', 'slightly_smiling_face', NOW(), NOW()),
    ('🤔', 'thinking_face', NOW(), NOW()),
    ('🤐', 'face_with_hand_over_mouth', NOW(), NOW()),
    ('👍', 'thumbs_up', NOW(), NOW()),
    ('❤️', 'heart', NOW(), NOW()),
    ('🎉', 'party_popper', NOW(), NOW()),
    ('🚀', 'rocket', NOW(), NOW()),
    ('👎', 'thumbs_down', NOW(), NOW()),
    ('😄', 'smile', NOW(), NOW()),
    ('😕', 'confused', NOW(), NOW()),
    ('👀', 'eyes', NOW(), NOW())
ON CONFLICT (name) DO NOTHING;