#!/bin/bash
# Autor: Tiago Rogato
# Site: https://trogato.wixsite.com/virtuasystem
# Facebook: https://www.facebook.com/TROGATO
# LinkedIn: https://www.linkedin.com/in/tiago-rogato-da-silveira-095563b6/
# Data de criação: 25/07/2020
# Data de atualização: 11/07/2025
# Versão: 0.07
# Testado e homologado para a versão do Debian GNU/Linux 12 Bookworm x64
# Kernel >= 6.1.x
# Testado e homologado para a versão do Grafana Server 11.2.x
#
# Grafana é uma aplicação web de análise de código aberto multiplataforma e visualização
# interativa da web. Ele fornece tabelas, gráficos e alertas para a Web quando conectado
# a fontes de dados suportadas. É expansível através de um sistema de plug-in.
#
# Site Oficial do Projeto Grafana: https://grafana.com/
#
# Soluções Open Source de Visualização de Dados
# Site Oficial do Projeto Metabase: https://www.metabase.com/
# Site Oficial do Projeto Wazuh: https://wazuh.com/
# Site Oficial do Projeto OpenSearch: https://opensearch.org/
# Site Oficial do Projeto Cyclotron: https://www.cyclotron.io/
#
# Informações que serão solicitadas na configuração via Web do Grafana
# Email or username: admin
# Password: admin: (Log In)
# Change Password
#	New password: pti@2018
#	Confirm new password: pti@2018: (Submit)
#
# Criando um Data Source do MySQL
# Dashboard
#	Data Sources
#	>Add data source
#		SQL
#			MySQL
#				Name: ptispo01ws01
#				MySQL Connection
#					Host: localhost:3306
#					Database: grafana
#					User: grafana
#					Password: grafana
#			<Save & Test>
#
# Dashboard
#	Dashboards
#		<+ Add visualization>
#			Query1
#				Data source: ptispo01ws01
#			Builder
#				Dataset: grafana   Tabela: contatos
#				Columm: nome   Aggregation: COUNT (Contar)   Alias: Choose (Default)
#			<Run query>
#			Panel Title
#				<Open visualization suggestions>
#					Suggestions: Gauge
#						Panel options
#							Tile: Total de Contatos
#							Description: Total de Contatos cadastrado no banco Grafana
#					<Save> - <Save>
#					<Apply>
#		<Add>
#			Visualization
#			Query1
#				Data source: ptispo01ws01
#			Builder
#				Dataset: grafana   Tabela: contatos
#				Columm: nome   Aggregation: Choose (Default)   Alias: Choose (Default)
#			<Run query>
#			Panel Title
#				<Switch to table>
#					Panel options
#						Tile: Contatos do Grafana
#						Description: Nome dos contatos do banco Grafana
#				<Save> - <Save>
#				<Apply>
#
# Declarando as variáveis para criação da Base de Dados do Grafana Server
USER="root"
PASSWORD="pti@2018"
#
# opção do comando create: create (criação), database (base de dados), character set (conjunto de caracteres),
# collate (comparar)
# opção do comando create: create (criação), user (usuário), identified by (identificado por - senha do usuário)
# opção do comando grant: grant (permissão), usage (uso em), *.* (todos os bancos/tabelas), to (para)
# opção do comando GRANT: grant (permissão), all (todos privilégios), on (em ou na), *.* (todos os bancos/tabelas)
# opção do comando FLUSH: flush (atualizar), privileges (recarregar as permissões)
DATABASE="CREATE DATABASE grafana character set utf8mb4 collate utf8mb4_bin;"
USERDATABASE="CREATE USER 'grafana'@'localhost' IDENTIFIED BY 'grafana';"
GRANTDATABASE="GRANT USAGE ON *.* TO 'grafana'@'localhost' IDENTIFIED BY 'grafana';"
GRANTALL="GRANT ALL PRIVILEGES ON grafana.* TO 'grafana'@'localhost';"
FLUSH="FLUSH PRIVILEGES;"
#
# Configuração da variável de Log utilizado nesse script
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
#
# Verificando se o usuário é Root e se a Distribuição é Debian 12
# [ ] = teste de expressão, && = operador lógico AND, == comparação de string, exit 1 = A maioria
# dos erros comuns na execução
clear
if [ "$(id -u)" == "0" ] && [ "$(lsb_release -rs)" == "12" ]
	then
		echo -e "O usuário é Root, continuando com o script..."
		echo -e "Distribuição é Debian 12, continuando com o script..."
		sleep 5
	else
		echo -e "Usuário não é Root ($(id -u)) ou a Distribuição não é Debian 12 ($(lsb_release -rs))"
		echo -e "Caso você não tenha executado o script com o comando: sudo -i"
		echo -e "Execute novamente o script para verificar o ambiente."
		exit 1
fi
#
# Verificando o acesso a Internet do servidor Debian
# [ ] = teste de expressão, exit 1 = A maioria dos erros comuns na execução
# $? código de retorno do último comando executado, ; execução de comando,
# opção do comando nc: -z (scan for listening daemons), -w (timeouts), 1 (one timeout), 443 (port)
if [ "$(nc -zw1 google.com 443 &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "Você tem acesso a Internet, continuando com o script..."
		sleep 5
	else
		echo -e "Você NÃO tem acesso a Internet, verifique suas configurações de rede IPV4"
		echo -e "e execute novamente este script."
		sleep 5
		exit 1
fi
#
# Verificando se a porta 3000 está sendo utilizada no servidor Debian
# [ ] = teste de expressão, == comparação de string, exit 1 = A maioria dos erros comuns na execução,
# $? código de retorno do último comando executado, ; execução de comando,
# opção do comando nc: -v (verbose), -z (DCCP mode), &> redirecionador de saída de erro
if [ "$(nc -vz 127.0.0.1 3000 &> /dev/null ; echo $?)" == "0" ]
	then
		echo -e "A porta: 3000 já está sendo utilizada nesse servidor."
		echo -e "Verifique o serviço associado a essa porta e execute novamente esse script.\n"
		sleep 5
		exit 1
	else
		echo -e "A porta: 3000 está disponível, continuando com o script..."
		sleep 5
fi
#
# Verificando se as dependências do Grafana Server estão instaladas
# opção do dpkg: -s (status), opção do echo: -e (interpretador de escapes de barra invertida),
# -n (permite nova linha), || (operador lógico OU), 2> (redirecionar de saída de erro STDERR),
# && = operador lógico AND, { } = agrupa comandos em blocos, [ ] = testa uma expressão, retornando
# 0 ou 1, -ne = é diferente (NotEqual)
echo -n "Verificando as dependências do Grafana Server, aguarde... "
	for name in mysql-server mysql-common apache2 php
	do
		[[ $(dpkg -s $name 2> /dev/null) ]] || {
			echo -en "\n\nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
			deps=1;
		}
	done
		[[ $deps -ne 1 ]] && echo "Dependências.: OK" || {
			echo -en "\nInstale as dependências acima e execute novamente este script\n";
			echo -en "Recomendo instalar o LAMP stack para resolver as dependências.\n"
			exit 1;
		}
		sleep 5
#
# Verificando se o script já foi executado mais de 1 (uma) vez nesse servidor
# OBSERVAÇÃO IMPORTANTE: OS SCRIPTS FORAM PROJETADOS PARA SEREM EXECUTADOS APENAS 1 (UMA) VEZ
if [ -f $LOG ]
	then
		echo -e "Script $0 já foi executado 1 (uma) vez nesse servidor..."
		echo -e "É recomendado analisar o arquivo de $LOG para informações de falhas ou erros"
		echo -e "na instalação e configuração do serviço de rede utilizando esse script..."
		echo -e "Todos os scripts foram projetados para serem executados apenas 1 (uma) vez."
		sleep 5
		exit 1
	else
		echo -e "Primeira vez que você está executando esse script, tudo OK, agora só aguardar..."
		sleep 5
fi
#
# Script de instalação do Grafana Server no Debian GNU/Linux 12 Bookworm
# opção do comando echo: -e (enable interpretation of backslash escapes), \n (new line)
# opção do comando hostname: -d (domain)
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Início do script $0 em: $(date +%d/%m/%Y-" sconf/("%H:%M")")\n" &>> $LOG
clear
echo
#
echo -e "Instalação do Grafana Server no Debian GNU/Linux 12 Bookworm\n"
echo -e "Porta padrão utilizada pelo Grafana Server.: TCP 3000\n"
echo -e "Após a instalação do Grafana Server acessar a URL: http://$(hostname -d | cut -d' ' -f1):3000\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet...\n"
sleep 5
#
echo -e "Adicionando o Repositório Main do Apt, aguarde..."
	# Main - Software de código aberto oficialmente suportado
	# opção do comando: &>> (redirecionar a saída padrão)
	apt-add-repository main &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Adicionando os Repositórios Contrib e Non-Free do Apt, aguarde..."
	# Contrib - Software de código aberto que depende de software não-livre
	# Non-Free - Software de código fechado
	# opção do comando: &>> (redirecionar a saída padrão)
	apt-add-repository contrib &>> $LOG
	apt-add-repository non-free &>> $LOG
echo -e "Repositórios adicionados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando todo o sistema operacional, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y upgrade &>> $LOG
	apt -y dist-upgrade &>> $LOG
echo -e "Sistema atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Removendo todos os software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Criando o Banco de Dados do Grafana Server, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando mysql: -u (user), -p (password), -e (execute)
	mysql -u $USER -p$PASSWORD -e "$DATABASE" &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$USERDATABASE" &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTDATABASE" &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$GRANTALL" &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$FLUSH" &>> $LOG
echo -e "Banco de Dados criado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando a Instalação e Configuração do Grafana Server, aguarde...\n"
sleep 5
#
echo -e "Instalando o Repositório do Grafana Server, aguarde..."
	# opção do comando: &>> (redirecionar de saída padrão)
	# opção do comando: | piper (conecta a saída padrão com a entrada padrão de outro comando)
	# opção do comando wget: -q (quiet) -O (output document file)
	wget -q -O - https://packages.grafana.com/gpg.key | apt-key add - &>> $LOG
	echo "deb https://packages.grafana.com/oss/deb stable main" > /etc/apt/sources.list.d/grafana.list
echo -e "Repositório instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando as listas do Apt com o novo Repositório do Grafana Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	apt update &>> $LOG
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalando o Grafana Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y install grafana &>> $LOG
echo -e "Grafana instalado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Atualizando os arquivos de configuração Grafana Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mv: -v (verbose)
	# opção do comando cp: -v (verbose)
	# opção do comando chmod: -v (verbose), 640 (User: RW-, Group: R--, Other: ---)
	# opção do comando chown: -v (verbose), :grafana (group)
	mv -v /etc/grafana/grafana.ini /etc/grafana/grafana.ini.old &>> $LOG
	cp -v conf/grafana/grafana.ini /etc/grafana/ &>> $LOG
	chmod 640 -v /etc/grafana/grafana.ini &>> $LOG
	chown :grafana /etc/grafana/grafana.ini &>> $LOG
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração grafana.ini, pressione <Enter> para continuar..."
	# opção do comando read: -s (Do not echo keystrokes)
	read -s
	vim /etc/grafana/grafana.ini
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Iniciando o serviço do Grafana Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl enable grafana-server &>> $LOG
	systemctl restart grafana-server &>> $LOG
echo -e "Serviço iniciado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando o serviço do Grafana Server, aguarde..."
	# opção do comando grep: -i (ignore case)
	echo -e "Grafana: $(systemctl status grafana-server | grep -i Active)"
echo -e "Serviço verificado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a versão do serviço instalado, aguarde..."
	# opção do comando dpkg-query: -W (show), -f (showformat), ${version} (package information), \n (newline)
	echo -e "Grafana..: $(dpkg-query -W -f '${version}\n' grafana)"
echo -e "Versão verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando a porta de conexão do Grafana Server, aguarde..."
	# opção do comando ss: -t (tcp), -n (numeric), -l (listening)
	# opção do comando grep: -i (ignore case)
	ss -tuln | grep -i ':3000'
echo -e "Porta verificada com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Grafana Server feita com Sucesso!!!."
	# script para calcular o tempo gasto
	# opção do comando date: +%T (Time)
	HORAFINAL=$(date +%T)
	# opção do comando date: -u (utc), -d (date), +%s (second since 1970)
	HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
	HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
	# opção do comando date: -u (utc), -d (date), 0 (string command), sec (force second), +%H (hour), %M (minute), %S (second)
	TEMPO=$(date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S")
	# $0 (variável de ambiente do nome do comando)
	echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Pressione <Enter> para concluir o processo."
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Fim do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG
read
exit 0
