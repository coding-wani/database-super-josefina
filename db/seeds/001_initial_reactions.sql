INSERT INTO reactions (id, emoji, name) VALUES
    ('reaction-1', '🥰', 'heart_eyes'),
    ('reaction-2', '😊', 'slightly_smiling_face'),
    ('reaction-3', '🤔', 'thinking_face'),
    ('reaction-4', '🤐', 'face_with_hand_over_mouth'),
    ('reaction-5', '👍', 'thumbs_up'),
    ('reaction-6', '❤️', 'heart'),
    ('reaction-7', '🎉', 'party_popper'),
    ('reaction-8', '🚀', 'rocket'),
    ('reaction-9', '👎', 'thumbs_down'),
    ('reaction-10', '😄', 'smile'),
    ('reaction-11', '😕', 'confused'),
    ('reaction-12', '👀', 'eyes')
ON CONFLICT (id) DO NOTHING;