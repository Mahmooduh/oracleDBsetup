#!/bin/bash

# Exit on error
set -e

echo "========================================================="
echo "Starting Oracle APEX latest (24.x) Installation..."
echo "========================================================="

# 1. Download and extract APEX
echo "Downloading Oracle APEX latest release..."
curl -o /opt/oracle/apex-latest.zip -L https://download.oracle.com/otn_software/apex/apex-latest.zip
cd /opt/oracle

echo "Extracting APEX..."
unzip -qo apex-latest.zip
rm apex-latest.zip

cd apex

echo "Installing APEX into Oracle 21c (This will take a while)..."
# 2. Install APEX and configure users
sqlplus -s / as sysdba <<EOF

-- Install APEX
@apexins.sql SYSAUX SYSAUX TEMP /i/

-- Configure ORDS REST users
@apex_rest_config_core.sql oracle/ords/ ${APP_USER_PASSWORD:-SecretPassword123!} ${APP_USER_PASSWORD:-SecretPassword123!}

-- Unlock and set password for APEX_PUBLIC_USER
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER IDENTIFIED BY "${APP_USER_PASSWORD:-SecretPassword123!}";

-- Create APEX Admin User
BEGIN
    FOR c IN (SELECT workspace_id FROM apex_workspaces WHERE workspace = 'INTERNAL') LOOP
        APEX_UTIL.SET_SECURITY_GROUP_ID( c.workspace_id );
    END LOOP;
    
    APEX_UTIL.CREATE_USER(
        p_user_name       => 'ADMIN',
        p_email_address   => 'admin@example.com',
        p_web_password    => '${APP_USER_PASSWORD:-SecretPassword123!}',
        p_developer_privs => 'ADMIN'
    );
    
    APEX_UTIL.SET_SECURITY_GROUP_ID( null );
    COMMIT;
END;
/
EXIT;
EOF

echo "========================================================="
echo "Oracle APEX Installation Completed Successfully."
echo "========================================================="
