# Zabbix and Grafana Installation on Debian 12 Bookworm

This repository contains scripts to automate the installation and configuration of **Zabbix Server 7.0** and **Grafana Server 11.2.0** on **Debian GNU/Linux 12 Bookworm**. These tools provide a powerful combination for monitoring and visualizing IT infrastructure:

- **Zabbix**: An enterprise-class open-source monitoring solution for networks, servers, virtual machines, and cloud services, offering metrics like CPU load, network bandwidth, and disk space, with flexible alerting mechanisms.[](https://github.com/zabbix/zabbix)
- **Grafana**: An open-source platform for analytics and interactive visualization, providing charts, graphs, and alerts when connected to supported data sources, extensible via plugins.

This project is designed to streamline the setup of a monitoring stack using Zabbix for data collection and Grafana for advanced visualization, integrated with MySQL, PHP, and Apache on Debian 12.

## Repository Contents

- **`zabbix.sh`**: Installs and configures Zabbix Server 7.0 with MySQL, PHP, Apache, and the Zabbix agent.
- **`grafana.sh`**: Installs and configures Grafana Server 11.2.0 for data visualization.
- **`00-parametros.sh`**: Configuration file containing variables (e.g., `GRAFANADEP`, `PORTGRAFANA`, `LOGSCRIPT`) used by `grafana.sh`.
- **`conf/`**: Directory containing configuration files for Zabbix and Grafana (e.g., `zabbix_server.conf`, `apache.conf`, `zabbix_agentd.conf`, `grafana.ini`).

## Prerequisites

Before running the scripts, ensure the following requirements are met:

- **Operating System**: Debian GNU/Linux 12 Bookworm x64
- **Kernel Version**: >= 6.1
- **User Privileges**: Scripts must be run as root (use `sudo -i`)
- **Dependencies**:
  - For Zabbix: `mysql-server`, `mysql-common`, `apache2`, `php`
  - For Grafana: Dependencies defined in `00-parametros.sh` (typically includes `mysql-server`, `mysql-common`, `apache2`, `php`)
  - Install manually if needed:
    ```bash
    sudo apt install mysql-server mysql-common apache2 php
    ```
- **Internet Connection**: Required for downloading repositories and packages.
- **LAMP Stack**: A pre-installed LAMP (Linux, Apache, MySQL, PHP) stack is recommended.
- **Port Availability**: Port 3000 must be free for Grafana.
- **Configuration File**: For `grafana.sh`, ensure `00-parametros.sh` is present and configured with variables like `GRAFANADEP`, `PORTGRAFANA` (default: 3000), and `LOGSCRIPT`.

## Installation Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/TRogato/ZABBIX-MYSQL-PHP-APACHE-DEB12.git
   cd ZABBIX-MYSQL-PHP-APACHE-DEB12
   ```

2. **Set Execute Permissions**:
   ```bash
   chmod +x zabbix.sh grafana.sh
   ```

3. **Run the Scripts as Root**:
   ```bash
   sudo -i
   ./zabbix.sh
   ./grafana.sh
   ```

4. **Zabbix Script (`zabbix.sh`) Actions**:
   - Verifies root privileges, Debian 12, and kernel (>=6.1).
   - Checks for dependencies and internet connectivity.
   - Adds Debian `main`, `contrib`, and `non-free` repositories.
   - Installs the Zabbix 7.0 repository and packages (`zabbix-server-mysql`, `zabbix-frontend-php`, `zabbix-apache-conf`, `zabbix-agent`, `traceroute`, `nmap`, `snmp`, `snmpd`, `snmp-mibs-downloader`).
   - Creates a MySQL database (`zabbix`) and user (`zabbix` with password `zabbix`).
   - Prompts for manual editing of configuration files (`/etc/zabbix/zabbix_server.conf`, `/etc/zabbix/apache.conf`, `/etc/zabbix/zabbix_agentd.conf`) using `vim`. Press `<Enter>` to edit, modify as needed, and save (`:wq`).
   - Enables and restarts Zabbix services and Apache.
   - Verifies ports 10050 and 10051.

5. **Grafana Script (`grafana.sh`) Actions**:
   - Verifies root privileges, Debian 12, internet connectivity, and port 3000 availability.
   - Checks for dependencies defined in `00-parametros.sh`.
   - Adds Debian `main`, `contrib`, and `non-free` repositories.
   - Installs the Grafana repository and package (`grafana`).
   - Updates configuration file (`/etc/grafana/grafana.ini`), backing up the original.
   - Prompts for manual editing of `/etc/grafana/grafana.ini` using `vim`. Press `<Enter>` to edit, modify as needed, and save (`:wq`).
   - Enables and restarts the Grafana service.
   - Verifies service status, installed version, and port 3000.

## Post-Installation Configuration

### Zabbix Configuration

1. **Access the Web Interface**:
   Open a browser and navigate to:
   ```
   http://<server-ip>/zabbix/
   ```
   Replace `<server-ip>` with your server's IP address (displayed during `zabbix.sh` execution).

2. **Web Configuration Steps**:
   - **Welcome to Zabbix 7.0**: Select language (default: English) and click *Next step*.
   - **Check of pre-requisites**: Ensure all checks pass, then click *Next step*.
   - **Configure DB connection**:
     - Database type: MySQL
     - Database host: `localhost`
     - Database port: `0` (default: 3306)
     - Database name: `zabbix`
     - Store credentials in: Plain text
     - User: `zabbix`
     - Password: `zabbix`
     - Click *Next step*.
   - **Zabbix server details**:
     - Host: `localhost`
     - Port: `10051`
     - Name: `ptispo01ws01` (or your preferred server name)
     - Click *Next step*.
   - **GUI settings**:
     - Default time zone: System
     - Default theme: Dark
     - Click *Next step*.
   - **Pre-installation summary**: Review and click *Next step*.
   - **Install**: Click *Finish*.

3. **Login**:
   - Default user: `Admin` (case-sensitive)
   - Default password: `zabbix`

### Grafana Configuration

1. **Access the Web Interface**:
   Open a browser and navigate to:
   ```
   http://<server-domain>:3000
   ```
   Replace `<server-domain>` with your server's domain or IP address (displayed during `grafana.sh` execution).

2. **Login**:
   - Username: `admin`
   - Password: `admin`
   - Change password:
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

## Integrating Zabbix with Grafana

To visualize Zabbix data in Grafana:

1. **Install the Zabbix Plugin for Grafana**:
   ```bash
   grafana-cli plugins install alexanderzobnin-zabbix-app
   ```
   Restart Grafana:
   ```bash
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

4. **Create Dashboards**:
   - Use Grafana’s query builder to create visualizations based on Zabbix metrics (e.g., CPU load, network traffic).
   - Refer to the [Grafana Zabbix plugin documentation](https://grafana.com/grafana/plugins/alexanderzobnin-zabbix-app/) for advanced configurations.

## Troubleshooting

- **Dependency Errors**: Install missing dependencies using `apt install` or set up a LAMP stack.
- **Database Issues**:
  - For Zabbix: Ensure MySQL is running (`systemctl status mysql`) and the `zabbix` database/user are configured.
  - For Grafana: Verify the `dbagenda` database and user credentials.
- **Port Issues**:
  - Zabbix: Check ports 10050 and 10051 (`ss -tuln | grep '10050\|10051'`).
  - Grafana: Check port 3000 (`ss -tuln | grep 3000`).
- **Configuration Files**: Check backed-up originals (e.g., `/etc/zabbix/zabbix_server.conf.bkp`, `/etc/grafana/grafana.ini.old`) if issues arise.
- **Service Failures**:
  ```bash
  systemctl status zabbix-server zabbix-agent apache2 grafana-server
  ```
- **Logs**: Review logs at the path specified in `LOGSCRIPT` (for Grafana) or `/var/log/zabbix.sh` (for Zabbix).

## Additional Information

- **Official Websites**:
  - Zabbix: [https://www.zabbix.com/](https://www.zabbix.com/)[](https://github.com/zabbix/zabbix)
  - Grafana: [https://grafana.com/](https://grafana.com/)
- **Related Open-Source Tools**:
  - Metabase: [https://www.metabase.com/](https://www.metabase.com/)
  - Wazuh: [https://wazuh.com/](https://wazuh.com/)
  - OpenSearch: [https://opensearch.org/](https://opensearch.org/)
  - Cyclotron: [https://www.cyclotron.io/](https://www.cyclotron.io/)
- **Support**: Refer to Zabbix and Grafana documentation or community forums for advanced configurations.

## Authors

- **Zabbix Script**: Robson Vaamonde
  - Website: [www.procedimentosemti.com.br](http://www.procedimentosemti.com.br)
  - Facebook: [ProcedimentosEmTI](https://facebook.com/ProcedimentosEmTI), [BoraParaPratica](https://facebook.com/BoraParaPratica)
  - YouTube: [BoraParaPratica](https://youtube.com/BoraParaPratica)
- **Grafana Script**: Tiago Rogato
  - Website: [https://trogato.wixsite.com/virtuasystem](https://trogato.wixsite.com/virtuasystem)
  - Facebook: [TROGATO](https://www.facebook.com/TROGATO)
  - LinkedIn: [Tiago Rogato da Silveira](https://www.linkedin.com/in/tiago-rogato-da-silveira-095563b6/)

## Contributing

Contributions are welcome! Please submit issues or pull requests to improve the scripts or documentation. Ensure changes are tested on Debian 12 with Zabbix 7.0 and Grafana 11.2.0.