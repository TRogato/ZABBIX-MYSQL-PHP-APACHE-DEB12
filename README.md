# Script de Instalação do Zabbix Server para Debian GNU/Linux 12

Este script automatiza a instalação e configuração do Zabbix Server 7.0 no Debian GNU/Linux 12 (Bookworm). O Zabbix é uma ferramenta de monitoramento de código aberto para diversos componentes de TI, incluindo redes, servidores, máquinas virtuais e serviços em nuvem. Ele fornece métricas como uso de largura de banda de rede, carga de CPU e consumo de espaço em disco, além de recursos de monitoramento e alertas.

## Pré-requisitos

Antes de executar o script, certifique-se de que os seguintes requisitos sejam atendidos:

- **Sistema Operacional**: Debian GNU/Linux 12 (Bookworm) x64
- **Versão do Kernel**: >= 6.1
- **Privilégios de Usuário**: O script deve ser executado como root (use `sudo -i`)
- **Dependências**: Os seguintes pacotes devem estar instalados:
  - `mariadb-server`
  - `mariadb-common`
  - `apache2`
  - `php`
- **Conexão com a Internet**: Necessária para baixar o repositório e pacotes do Zabbix.
- **LAMP Stack**: Recomenda-se ter um stack LAMP (Linux, Apache, MariaDB, PHP) pré-instalado. Você pode usar um script `lamp.sh` para configurá-lo, se necessário.

Para instalar as dependências manualmente, execute:
```bash
sudo apt install mariadb-server mariadb-common apache2 php
```

## Visão Geral do Script

- **Arquivo**: `zabbix.sh`
- **Versão**: 0.06
- **Última Atualização**: 09/07/2025
- **Objetivo**: Instala e configura o Zabbix Server 7.0, incluindo o banco de dados, frontend e agente, no Debian 12.
- **Saída de Log**: Os logs são salvos em `/var/log/zabbix.sh`.

## Passos de Instalação

1. **Baixar o Script**:
   Certifique-se de que o script `zabbix.sh` esteja disponível no seu sistema. Você pode copiá-lo para o servidor ou baixá-lo do repositório.

2. **Definir Permissões de Execução**:
   ```bash
   chmod +x zabbix.sh
   ```

3. **Executar o Script como Root**:
   ```bash
   sudo -i
   ./zabbix.sh
   ```

4. **Seguir as Instruções**:
   - O script verifica privilégios de root, versão do Debian (12) e kernel (>=6.1).
   - Ele verifica as dependências e interrompe a execução se alguma estiver faltando, solicitando sua instalação.
   - O script pausará em determinados momentos para permitir a edição manual dos arquivos de configuração (`/etc/zabbix/zabbix_server.conf`, `/etc/zabbix/apache.conf`, `/etc/zabbix/zabbix_agentd.conf`). Pressione `<Enter>` para abrir esses arquivos no `vim`. Modifique conforme necessário ou salve e saia (`:wq`).

5. **Ações do Script**:
   - Adiciona o repositório oficial do Zabbix 7.0.
   - Atualiza o sistema e instala os pacotes do Zabbix.
   - Instala o Zabbix Server, frontend, configuração do Apache e agente, além de ferramentas adicionais (`traceroute`, `nmap`, `snmp`, `snmpd`, `snmp-mibs-downloader`).
   - Cria um banco de dados MariaDB (`zabbix`) e usuário (`zabbix` com senha `zabbix`).
   - Popula o banco de dados com o esquema do Zabbix.
   - Configura e reinicia os serviços do Zabbix e Apache.
   - Verifica as portas em escuta (10050 e 10051).

## Configuração Pós-Instalação

Após a conclusão do script, configure o Zabbix por meio da interface web:

1. **Acessar a Interface Web**:
   Abra um navegador e acesse:
   ```
   http://<ip-do-servidor>/zabbix/
   ```
   Substitua `<ip-do-servidor>` pelo endereço IP do seu servidor (exibido durante a execução do script).

2. **Passos de Configuração Web**:
   Siga as instruções na tela:
   - **Bem-vindo ao Zabbix 7.0**: Selecione o idioma (padrão: Inglês) e clique em *Próximo passo*.
   - **Verificação de pré-requisitos**: Confirme que todas as verificações passaram, depois clique em *Próximo passo*.
   - **Configurar conexão com o banco de dados**:
     - Tipo de banco de dados: MariaDB
     - Host do banco de dados: `localhost`
     - Porta do banco de dados: `0` (padrão: 3306)
     - Nome do banco de dados: `zabbix`
     - Armazenar credenciais em: Texto simples
     - Usuário: `zabbix`
     - Senha: `zabbix`
     - Clique em *Próximo passo*.
   - **Detalhes do servidor Zabbix**:
     - Host: `localhost`
     - Porta: `10051`
     - Nome: `ptispo01ws01` (ou o nome de servidor desejado)
     - Clique em *Próximo passo*.
   - **Configurações da interface gráfica**:
     - Fuso horário padrão: Sistema
     - Tema padrão: Escuro
     - Clique em *Próximo passo*.
   - **Resumo de pré-instalação**: Revise e clique em *Próximo passo*.
   - **Instalar**: Clique em *Concluir*.

3. **Login**:
   - Usuário padrão: `Admin` (sensível a maiúsculas)
   - Senha padrão: `zabbix`

## Solução de Problemas

- **Erros de Dependências**: Se o script reportar dependências ausentes, instale-as usando o comando `apt install` sugerido ou configure o stack LAMP.
- **Problemas com o Banco de Dados**: Certifique-se de que o MariaDB está em execução (`systemctl status mariadb`).
- **Problemas de Porta**: Verifique se as portas 10050 e 10051 estão abertas com `ss -tuln`.
- **Arquivos de Configuração**: Verifique os arquivos de backup originais (`*.bkp`) se houver problemas após a edição.
- **Falhas de Serviço**: Verifique o status dos serviços com:
  ```bash
  systemctl status zabbix-server
  systemctl status zabbix-agent
  systemctl status apache2
  ```

## Informações Adicionais

- **Site Oficial do Zabbix**: [https://www.zabbix.com/](https://www.zabbix.com/)
- **Arquivo de Log**: `/var/log/zabbix.sh`
- **Suporte**: Consulte a documentação oficial do Zabbix ou fóruns da comunidade para configurações avançadas.

## Autor

- **Robson Vaamonde**
- **Website**: [www.procedimentosemti.com.br](http://www.procedimentosemti.com.br)
- **Facebook**: [ProcedimentosEmTI](https://facebook.com/ProcedimentosEmTI), [BoraParaPratica](https://facebook.com/BoraParaPratica)
- **YouTube**: [BoraParaPratica](https://youtube.com/BoraParaPratica)
