# DOE ERTL OSMS Scan

## Project Overview
This project provides a WordPress environment with Apache and PHP, designed for scanning and testing purposes. It uses Docker Compose for easy setup and management.

## Prerequisites
- Docker
- Docker Compose

## Setup Instructions

1. **Clone the repository**
   ```sh
   git clone <your-repo-url>
   cd doe_ertl_osms_scan
   ```

2. **Start the application**
   ```sh
   docker-compose up -d
   ```
   This command will build and start the Apache/PHP and WordPress containers in the background.

3. **Access WordPress**
   - Open your browser and go to: `http://localhost:8080` (or the port specified in your `docker-compose.yml`)

4. **Stop the application**
   ```sh
   docker-compose down
   ```
   This will stop and remove the containers.

## Additional Notes
- SSL certificates are managed in the `apache-php/certs/` directory.
- Custom Apache configuration is in `apache-php/conf/ssl.conf`.
- WordPress files are located in the `wordpress/` directory.
- For troubleshooting, check container logs:
  ```sh
  docker-compose logs
  ```

## Customization
- To add plugins or themes, place them in the appropriate subfolders under `wordpress/wp-content/`.
- To change Apache or PHP settings, edit the files in `apache-php/conf/` and rebuild the container.

## License
See LICENSE file for details.

## How to Migrate WordPress

To migrate your WordPress site and database to another server or environment, follow these steps:

Display siteurl and home
```
SELECT option_name, option_value 
FROM jkmty0ny5_options 
WHERE option_name IN ('siteurl', 'home');
```


1. **Export the WordPress Database**
   - Run the following command on your source server to export the database:
     ```sh
     mysqldump -u <user> -p <source_db> > wordpress_backup.sql
     ```

2. **Copy Files and SQL Backup**
   - Copy the entire `wordpress/` directory and the `wordpress_backup.sql` file to your new server or environment.

3. **Import the Database**
   - On the target server, create a new database (if needed):
     ```sql
     CREATE DATABASE <target_db> CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
     ```
   - Import the backup:
     ```sh
     mysql -u <user> -p <target_db> < wordpress_backup.sql
     ```

4. **Update Site URLs (if domain changes)**
   - Update the site URL and home URL in the database:
   ```
   UPDATE jkmty0ny5_options SET option_value = replace(option_value, 'old site', 'new site') WHERE option_name = 'home' OR option_name = 'siteurl';

   UPDATE jkmty0ny5_posts SET guid = replace(guid, 'old site', 'new site');

   UPDATE jkmty0ny5_posts SET post_content = replace(post_content, 'old site', 'new site');
   
   UPDATE jkmty0ny5_postmeta SET meta_value = replace(meta_value,'old site', 'new site');
   ```
5. **Flush Rewrite Rules**
   - Log in to the WordPress admin dashboard and visit Settings > Permalinks, then click "Save Changes". Alternatively, use WP-CLI:
     ```sh
     wp rewrite flush
     ```

6. **Reference**
   - See the `migrate_wordpress.sql` file in this project for a sample migration script.

## SSL Certificates and Certbot Integration

This project supports SSL certificate management using Certbot and Let's Encrypt.

### How to Use Certbot with Docker Compose

1. **Copy the example Compose file**
   ```sh
   cp docker-compose.certbot.example.yml docker-compose.yml
   ```
   Or manually add the `certbot` service and shared volumes to your existing `docker-compose.yml`.

2. **Obtain a Certificate**
   Replace `yourdomain.com` and `you@example.com` with your actual domain and email:
   ```sh
   docker compose run --rm certbot certonly --webroot -w /var/www/html -d yourdomain.com --email you@example.com --agree-tos --no-eff-email
   ```
   Certificates will be saved in the shared `certbot-etc` volume and available to Apache.

3. **Configure Apache for SSL**
   Make sure your Apache config in `apache-php/conf/ssl.conf` points to the certificates in `/etc/letsencrypt/live/yourdomain.com/`.

4. **Renew Certificates**
   To renew all certificates:
   ```sh
   docker compose run --rm certbot renew
   ```

5. **Restart Apache after Renewal**
   ```sh
   docker compose restart apache-php
   ```

### Manual Apache SSL Configuration After Certbot

After obtaining your certificate with certbot, you must manually configure Apache to use the new certificates:

1. **Run certbot in webroot mode** (replace with your domain and email):
   ```sh
   docker compose run --rm certbot certonly --webroot -w /var/www/html -d yourdomain.com --email you@example.com --agree-tos --no-eff-email
   ```

2. **Update your Apache SSL config** (e.g., `apache-php/conf/ssl.conf`) to use the generated certificates:
   ```apache
   SSLCertificateFile /etc/letsencrypt/live/yourdomain.com/fullchain.pem
   SSLCertificateKeyFile /etc/letsencrypt/live/yourdomain.com/privkey.pem
   ```

3. **Restart the Apache container**:
   ```sh
   docker compose restart apache-php
   ```

Certbot cannot automatically configure Apache inside the container, so these steps are required after obtaining or renewing certificates.

**Note:**
- The `certbot` container does not run continuously; use it for obtaining and renewing certificates.
- Ensure your domain points to your server's public IP and ports 80/443 are open.
