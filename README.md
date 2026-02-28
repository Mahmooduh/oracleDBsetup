# Oracle 21c + APEX 24 Docker Development Environment

This folder provides a complete, automated setup for Oracle Database 21c and Oracle APEX 24 + ORDS using Docker.

## Files included
1. `docker-compose.yml`: Defines the `database` (Oracle 21c) and `ords` (Oracle REST Data Services) containers, networks, and volumes.
2. `Dockerfile.db`: A custom image based on `gvenzl/oracle-xe:21` that adds the APEX installation script.
3. `01_install_apex.sh`: The initialization script that automatically downloads and installs the latest APEX 24.x zip from Oracle and sets up the admin user during the container's first run.

## Linux Server Deployment Instructions

Because these files were generated on a Windows machine, the shell script might contain Windows line endings (CRLF), which will cause errors when executed in a Linux container. 

Before running `docker-compose`, make sure you transfer these files to your Linux server and convert line endings for the shell script.

1. **Transfer the files to your Linux Server**
   Use `scp`, SFTP, or Git to copy the `oracle-apex` folder to your Linux server.
   ```bash
   scp -r c:/Users/daniPC/Documents/Fabulous/oracle-apex user@your_linux_server_ip:/path/to/destination
   ```

2. **Fix line endings and set permissions (Run on your Linux Server)**
   SSH into your Linux server, navigate to the folder, and run:
   ```bash
   cd /path/to/destination/oracle-apex
   
   # Convert Windows CRLF to Linux LF for the shell script
   sed -i 's/\r$//' 01_install_apex.sh
   
   # Make the script executable
   chmod +x 01_install_apex.sh
   ```

3. **Build and start the containers**
   ```bash
   docker compose up -d --build
   ```

4. **Wait for Initialization**
   The first startup will take 10-20 minutes, as it needs to:
   - Start Oracle 21c XE
   - Download the latest APEX 24 schema
   - Install APEX into the database (this step is the longest)
   
   You can monitor the progress with:
   ```bash
   docker logs -f oracle-21c-apex
   ```
   Wait until you see `Oracle APEX Installation Completed Successfully.` in the logs.

3. **Access Oracle APEX**
   Once both the database and ORDS containers are healthy, open your browser to:
   ```
   http://localhost:8080/ords/
   ```
   
   **Login Details:**
   - Workspace: `INTERNAL`
   - Username: `ADMIN`
   - Password: `SecretPassword123!`

## Customization
If you want to use a custom password instead of `SecretPassword123!`, simply update the `APP_USER_PASSWORD`, `ORACLE_PASSWORD`, and `ORDS_PWD` variables in `docker-compose.yml` before starting the containers.
