INSERT INTO reactions (emoji, name) VALUES
    ('🥰', 'heart_eyes'),
    ('😊', 'slightly_smiling_face'),
    ('🤔', 'thinking_face'),
    ('🤐', 'face_with_hand_over_mouth'),
    ('👍', 'thumbs_up'),
    ('❤️', 'heart'),
    ('🎉', 'party_popper'),
    ('🚀', 'rocket'),
    ('👎', 'thumbs_down'),
    ('😄', 'smile'),
    ('😕', 'confused'),
    ('👀', 'eyes')
ON CONFLICT (name) DO NOTHING;