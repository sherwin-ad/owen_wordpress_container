-- migrate_wordpress.sql
-- SQL script for migrating a WordPress database
-- This script assumes you are using MySQL/MariaDB
-- Replace 'source_db', 'target_db', 'user', and 'password' as needed

-- 1. Export the source database (run in terminal, not SQL):
-- mysqldump -u user -p source_db > wordpress_backup.sql

-- 2. Create the target database (if not exists):
CREATE DATABASE IF NOT EXISTS target_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 3. Import the backup into the target database (run in terminal, not SQL):
-- mysql -u user -p target_db < wordpress_backup.sql

-- 4. (Optional) Update site URL and home URL if domain changes:
-- UPDATE wp_options SET option_value = 'https://newsite.com' WHERE option_name IN ('siteurl', 'home');

-- 5. (Optional) Update URLs in posts and meta tables:
-- UPDATE wp_posts SET guid = REPLACE(guid, 'https://oldsite.com', 'https://newsite.com');
-- UPDATE wp_posts SET post_content = REPLACE(post_content, 'https://oldsite.com', 'https://newsite.com');
-- UPDATE wp_postmeta SET meta_value = REPLACE(meta_value, 'https://oldsite.com', 'https://newsite.com');

-- 6. (Optional) Flush rewrite rules (run in WordPress admin or via WP-CLI):
-- wp rewrite flush

-- End of migration script
