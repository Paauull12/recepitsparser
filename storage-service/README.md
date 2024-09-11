Database creation on Ubuntu:

-- Enter MariaDB
sudo mysql;

-- Create the database
CREATE DATABASE storage_service;

-- Switch to the database
USE storage_service;

-- Create a user with privileges on the database
CREATE USER 'storage_user'@'localhost' IDENTIFIED BY 'pleinciel';

-- Grant privileges to the user on the database
GRANT USAGE ON * . * TO 'storage_service_user'@'%' IDENTIFIED BY 'pleinciel' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
GRANT ALL PRIVILEGES ON `storage_service` . * TO 'storage_service_user'@'%';

-- Flush privileges to apply changes
FLUSH PRIVILEGES;

-- Create the Images table
CREATE TABLE IF NOT EXISTS Images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    image LONGBLOB NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
