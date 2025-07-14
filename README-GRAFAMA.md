# Grafana Server Installation Script for Debian GNU/Linux 12 Bookworm

This script automates the installation and configuration of **Grafana Server 11.2.0** on **Debian GNU/Linux 12 Bookworm**. Grafana is an open-source, multi-platform web application for analytics and interactive visualization, providing charts, graphs, and alerts when connected to supported data sources. It is extensible through a plug-in system, making it ideal for visualizing data from sources like Zabbix or MySQL/MariaDB.

This script is part of the [ZABBIX-MYSQL-PHP-APACHE-DEB12](https://github.com/TRogato/ZABBIX-MYSQL-PHP-APACHE-DEB12) project, designed to work alongside the Zabbix installation script (`zabbix.sh`) for a comprehensive monitoring and visualization stack.

## Prerequisites

Before running the script, ensure the following requirements are met:

- **Operating System**: Debian GNU/Linux 12 Bookworm x64
- **Kernel Version**: >= 6.1
- **User Privileges**: Script must be run as root (use `sudo -i`)
- **Dependencies**: The following packages must be installed:
  - `mariadb-server` (or `mysql-server` for MySQL compatibility)
  - `mysql-common`
  - `apache2`
  - `php`
  - Install manually if needed:
    ```bash
    sudo apt install mariadb-server mysql-common apache2 php -y
    ```
- **Internet Connection**: Required for downloading the Grafana repository and packages.
- **LAMP Stack**: A pre-installed LAMP (Linux, Apache, MySQL/MariaDB, PHP) stack is recommended for compatibility with both Grafana and Zabbix.
- **Port Availability**: Port 3000 must be free for Grafana.
- **Configuration File**: Ensure the `conf/grafana/grafana.ini` file is present in the repository’s `conf/` directory for configuration, or manually configure `/etc/grafana/grafana.ini` after installation.
- **MariaDB/MySQL Root Credentials**: The script uses the root user (`root`) with password `pti@2018` to create the Grafana database. Ensure these credentials are set:
  ```bash
  sudo mysql_secure_installation
  ```
  Set the root password to `pti@2018` or update the `USER` and `PASSWORD` variables in `grafana.sh`.

## Script Overview

- **File**: `grafana.sh`
- **Version**: 0.09
- **Last Updated**: 14/07/2025
- **Purpose**: Installs and configures Grafana Server 11.2.0 on Debian 12, including repository setup, package installation, MariaDB/MySQL database creation, and service configuration.
- **Log Output**: Logs are saved to `/var/log/grafana.sh`.

## Installation Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/TRogato/ZABBIX-MYSQL-PHP-APACHE-DEB12.git
   cd ZABBIX-MYSQL-PHP-APACHE-DEB12
   ```

2. **Set Execute Permissions**:
   ```bash
   chmod +x grafana.sh
   ```

3. **Run the Script as Root**:
   ```bash
   sudo -i
   ./grafana.sh
   ```

4. **Script Actions**:
   - Verifies root privileges, Debian 12, kernel (>=6.1), internet connectivity, and port 3000 availability.
   - Checks for dependencies (`mariadb-server`, `mysql-common`, `apache2`, `php`) and exits if any are missing, prompting installation.
   - Adds Debian `main`, `contrib`, and `non-free` repositories.
   - Updates the system and installs the Grafana OSS repository (`https://apt.grafana.com`).
   - Installs the `grafana` package.
   - Creates a MariaDB/MySQL database (`grafana`) and user (`grafana` with password `grafana`).
   - Updates configuration files, backing up the original `/etc/grafana/grafana.ini` and copying `conf/grafana/grafana.ini` (if available).
   - Prompts for manual editing of `/etc/grafana/grafana.ini` using `vim`. Press `<Enter>` to edit, configure the database section (see below), and save (`:wq`).
   - Sets appropriate permissions for configuration files.
   - Enables and restarts the Grafana service.
   - Verifies the service status, installed version, and port 3000.

5. **Configure `/etc/grafana/grafana.ini`**:
   During the script’s prompt, ensure the database section is configured as follows:
   ```ini
   [database]
   type = mysql
   host = 127.0.0.1:3306
   name = grafana
   user = grafana
   password = grafana
   ```

## Post-Installation Configuration

After the script completes, configure Grafana via the web interface:

1. **Access the Web Interface**:
   Open a browser and navigate to:
   ```
   http://<server-domain>:3000
   ```
   Replace `<server-domain>` with your server’s domain or IP address (displayed during script execution).

2. **Login**:
   - Username: `admin`
   - Password: `admin`
   - Change the password:
     - New password: `pti@2018`
     - Confirm new password: `pti@2018`
     - Click *Submit*.

3. **Configure a MySQL Data Source**:
   - Navigate to **Dashboard** > **Data Sources** > **Add data source**.
   - Select **SQL** > **MySQL**.
   - Configure:
     - **Name**: `ptispo01ws01`
     - **Host**: `localhost:3306`
     - **Database**: `grafana`
     - **User**: `grafana`
     - **Password**: `grafana`
   - Click **Save & Test**.

4. **Create Dashboards**:
   - Navigate to **Dashboards** > **+ Add visualization**.
   - **Query 1**:
     - **Data source**: `ptispo01ws01`
     - **Builder**:
       - Dataset: `grafana`
       - Table: `contatos`
       - Column: `nome`
       - Aggregation: `COUNT`
       - Alias: Choose (Default)
     - Click **Run query**.
     - **Panel Title**:
       - Open visualization suggestions, select **Gauge**.
       - **Panel options**:
         - Title: `Total de Contatos`
         - Description: `Total de Contatos cadastrado no banco Grafana`
       - Click **Save** > **Save** > **Apply**.
   - **Add Another Visualization**:
     - Select **Visualization**.
     - **Query 1**:
       - **Data source**: `ptispo01ws01`
       - **Builder**:
         - Dataset: `grafana`
         - Table: `contatos`
         - Column: `nome`
         - Aggregation: Choose (Default)
         - Alias: Choose (Default)
       - Click **Run query**.
       - **Panel Title**:
         - Switch to **Table**.
         - **Panel options**:
           - Title: `Contatos do Grafana`
           - Description: `Nome dos contatos do banco Grafana`
         - Click **Save** > **Save** > **Apply**.

## Integration with Zabbix

To visualize Zabbix data in Grafana (assuming `zabbix.sh` has been run):

1. **Install the Zabbix Plugin**:
   ```bash
   grafana-cli plugins install alexanderzobnin-zabbix-app
   systemctl restart grafana-server
   ```

2. **Enable the Plugin**:
   - In Grafana, navigate to **Configuration** > **Plugins**.
   - Find and enable the **Zabbix** plugin.

3. **Add Zabbix Data Source**:
   - Go to **Dashboard** > **Data Sources** > **Add data source**.
   - Select **Zabbix**.
   - Configure:
     - **URL**: `http://<server-ip>/zabbix/api_jsonrpc.php`
     - **Username**: `Admin`
     - **Password**: `zabbix`
     - Enable **Trends** for historical data.
   - Click **Save & Test**.

4. **Create Zabbix Dashboards**:
   - Use Grafana’s query builder to create visualizations for Zabbix metrics (e.g., CPU load, network traffic).
   - Refer to the [Grafana Zabbix plugin documentation](https://grafana.com/grafana/plugins/alexanderzobnin-zabbix-app/) for advanced configurations.

## Troubleshooting

- **Dependency Errors**:
  - Ensure all dependencies are installed:
    ```bash
    dpkg -s mariadb-server mysql-common apache2 php
    ```
  - Install missing packages:
    ```bash
    sudo apt install mariadb-server mysql-common apache2 php -y
    ```

- **Database Issues**:
  - Verify MariaDB/MySQL is running:
    ```bash
    systemctl status mysql
    ```
  - Check the `grafana` database and user:
    ```bash
    mysql -u root -ppti@2018 -e "SELECT User, Host FROM mysql.user; SHOW DATABASES;"
    ```

- **Port Issues**:
  - Verify port 3000 is open:
    ```bash
    ss -tuln | grep 3000
    ```

- **Configuration Files**:
  - Check the backed-up original (`/etc/grafana/grafana.ini.old`) if issues arise after editing.
  - Ensure `conf/grafana/grafana.ini` exists in the repository, or manually configure `/etc/grafana/grafana.ini`.

- **Service Failures**:
  - Check service status:
    ```bash
    systemctl status grafana-server
    ```
  - Review logs:
    ```bash
    cat /var/log/grafana.sh
    ```

## Additional Information

- **Official Grafana Website**: [https://grafana.com/](https://grafana.com/)
- **Log File**: `/var/log/grafana.sh`
- **Support**: Refer to the [Grafana documentation](https://grafana.com/docs/grafana/latest/) or community forums for advanced configurations.

## Author

- **Tiago Rogato**
- **Website**: [https://trogato.wixsite.com/virtuasystem](https://trogato.wixsite.com/virtuasystem)
- **Facebook**: [TROGATO](https://www.facebook.com/TROGATO)
- **LinkedIn**: [Tiago Rogato da Silveira](https://www.linkedin.com/in/tiago-rogato-da-silveira-095563b6/)