UPDATE users
SET password = '$argon2id$v=19$m=65536,t=3,p=4$YOUR_HASH_HERE'
WHERE LOWER(email) = LOWER('prof@example.com');

-- Verify the update
SELECT id, username, email, role, is_activated
FROM users
WHERE LOWER(email) = LOWER('prof@example.com');
