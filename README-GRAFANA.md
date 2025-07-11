# Grafana Server Installation Script for Debian GNU/Linux 12 Bookworm

This script automates the installation and configuration of Grafana Server 11.2.0 on Debian GNU/Linux 12 (Bookworm). Grafana is an open-source, multi-platform web application for analytics and interactive visualization, providing charts, graphs, and alerts when connected to supported data sources. It is extensible through a plug-in system.

## Prerequisites

Before running the script, ensure the following requirements are met:

- **Operating System**: Debian GNU/Linux 12 Bookworm x64
- **Kernel Version**: >= 6.1
- **User Privileges**: Script must be run as root (use `sudo -i`)
- **Dependencies**: The following packages must be defined in `00-parametros.sh` (e.g., `mysql-server`, `mysql-common`, `apache2`, `php`). Typically, a LAMP stack is required.
- **Internet Connection**: Required for downloading the Grafana repository and packages.
- **LAMP Stack**: It is recommended to have a LAMP (Linux, Apache, MySQL, PHP) stack pre-installed. You can install dependencies manually or use a LAMP setup script if needed.

To install dependencies manually (example):
```bash
sudo apt install mysql-server mysql-common apache2 php
```

- **Configuration File**: Ensure the `00-parametros.sh` file is present in the same directory as the script, defining variables such as `GRAFANADEP` (dependencies), `PORTGRAFANA` (default: 3000), and `LOGSCRIPT` (log file path).

## Script Overview

- **File**: `grafana.sh`
- **Version**: 0.06
- **Last Updated**: 11/07/2025
- **Purpose**: Installs and configures Grafana Server 11.2.0 on Debian 12, including repository setup, package installation, and service configuration.
- **Log Output**: Logs are saved to the path specified in `LOGSCRIPT` (defined in `00-parametros.sh`).

## Installation Steps

1. **Download the Script**:
   Ensure the `grafana.sh` and `00-parametros.sh` scripts are available on your system. You can copy them to your server or download them from the repository.

2. **Set Execute Permissions**:
   ```bash
   chmod +x grafana.sh
   ```

3. **Run the Script as Root**:
   ```bash
   sudo -i
   ./grafana.sh
   ```

4. **Follow Prompts**:
   - The script checks for root privileges and Debian 12.
   - It verifies internet connectivity and ensures port 3000 is available.
   - It checks for dependencies listed in `GRAFANADEP` and exits if any are missing, prompting you to install them.
   - The script pauses to allow manual editing of the configuration file `/etc/grafana/grafana.ini`. Press `<Enter>` to open the file in `vim`. Modify as needed or save and exit (`:wq`).

5. **Script Actions**:
   - Adds Debian `main`, `contrib`, and `non-free` repositories.
   - Updates the system and installs the Grafana repository.
   - Installs the Grafana Server package.
   - Updates configuration files, backing up originals and applying new ones from `conf/grafana/grafana.ini`.
   - Sets appropriate permissions for configuration files.
   - Enables and restarts the Grafana service.
   - Verifies the service status, installed version, and port 3000.

## Post-Installation Configuration

After the script completes, configure Grafana via the web interface:

1. **Access the Web Interface**:
   Open a browser and navigate to:
   ```
   http://<server-domain>:3000
   ```
   Replace `<server-domain>` with your server's domain or IP address (displayed during script execution).

2. **Login**:
   - Username: `admin`
   - Password: `admin`
   - After logging in, you will be prompted to change the password. Use:
     - New password: `pti@2018`
     - Confirm new password: `pti@2018`
     - Click *Submit*.

3. **Configure a MySQL Data Source**:
   - Navigate to **Dashboard** > **Data Sources** > **Add data source**.
   - Select **SQL** > **MySQL**.
   - Configure:
     - **Name**: `ptispo01ws01`
     - **Host**: `localhost:3306`
     - **Database**: `dbagenda`
     - **User**: `dbagenda`
     - **Password**: `dbagenda`
   - Click **Save & Test**.

4. **Create Dashboards**:
   - Navigate to **Dashboards** > **+ Add visualization**.
   - **Query 1**:
     - **Data source**: `ptispo01ws01`
     - **Builder**:
       - Dataset: `dbagenda`
       - Table: `contatos`
       - Column: `nome`
       - Aggregation: `COUNT`
       - Alias: Choose (Default)
     - Click **Run query**.
     - **Panel Title**:
       - Open visualization suggestions, select **Gauge**.
       - **Panel options**:
         - Title: `Total de Contatos`
         - Description: `Total de Contatos cadastrado no banco DBAgenda`
       - Click **Save** > **Save** > **Apply**.
   - **Add Another Visualization**:
     - Select **Visualization**.
     - **Query 1**:
       - **Data source**: `ptispo01ws01`
       - **Builder**:
         - Dataset: `dbagenda`
         - Table: `contatos`
         - Column: `nome`
         - Aggregation: Choose (Default)
         - Alias: Choose (Default)
       - Click **Run query**.
       - **Panel Title**:
         - Switch to **Table**.
         - **Panel options**:
           - Title: `Contatos do DBAgenda`
           - Description: `Nome dos contatos do banco DBAgenda`
         - Click **Save** > **Save** > **Apply**.

## Troubleshooting

- **Dependency Errors**: If the script reports missing dependencies, install them using the suggested `apt install` command or set up a LAMP stack.
- **Database Issues**: Ensure MySQL is running (`systemctl status mysql`) and the `dbagenda` database and user are correctly configured.
- **Port Issues**: Verify port 3000 is open using `ss -tuln | grep 3000`.
- **Configuration Files**: Check the backed-up original (`/etc/grafana/grafana.ini.old`) if issues arise after editing.
- **Service Failures**: Check service status with:
  ```bash
  systemctl status grafana-server
  ```

## Additional Information

- **Official Grafana Website**: [https://grafana.com/](https://grafana.com/)
- **Log File**: Path specified in `LOGSCRIPT` (from `00-parametros.sh`)
- **Support**: Refer to the Grafana documentation or community forums for advanced configurations.

## Author

- **Tiago Rogato**
- **Website**: [https://trogato.wixsite.com/virtuasystem](https://trogato.wixsite.com/virtuasystem)
- **Facebook**: [TROGATO](https://www.facebook.com/TROGATO)
- **LinkedIn**: [Tiago Rogato da Silveira](https://www.linkedin.com/in/tiago-rogato-da-silveira-095563b6/)