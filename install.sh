#!/bin/bash

read -sp 'Enter the SQL Server system administrator password: ' sa_password
echo
apt install nala sudo -y
clear
nala update
nala upgrade -y
sudo nala install gnupg2 apt-transport-https wget curl ufw neofetch expect -y
wget -q -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null 2>&1
echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg arch=amd64,armhf,arm64] https://packages.microsoft.com/ubuntu/22.04/mssql-server-2022 jammy main" | sudo tee /etc/apt/sources.list.d/mssql-server-2022.list
clear
timedatectl set-timezone America/Sao_Paulo
sudo nala update
sudo nala install mssql-server -y
cat << 'EOF' > setup_mssql.exp
#!/usr/bin/expect -f

set sa_password [lindex $argv 0]
spawn sudo /opt/mssql/bin/mssql-conf setup
expect "Enter your edition choice"
send "8\r"
expect "Enter the product key"
send "J4V48-P8MM4-9N3J9-HD97X-DYMRM\r"
expect "Is the product selected covered by Software Assurance"
send "Yes\r"
expect "Do you accept the license terms"
send "Yes\r"
expect "Enter the SQL Server system administrator password:"
send "$sa_password\r"
expect "Confirm the SQL Server system administrator password:"
send "$sa_password\r"
expect eof
EOF
chmod +x setup_mssql.exp
./setup_mssql.exp "$sa_password"
rm -rf setup_mssql.exp
sudo systemctl enable mssql-server
sudo systemctl start mssql-server
sudo systemctl is-enabled mssql-server
sudo systemctl status mssql-server --no-pager
sudo ufw allow OpenSSH
sudo ufw allow 1433/tcp
sudo ufw enable
echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg arch=amd64,armhf,arm64] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" | sudo tee /etc/apt/sources.list.d/prod.list
sudo nala update
sudo ACCEPT_EULA=Y nala install mssql-tools unixodbc-dev -y
ls -ah /opt/mssql-tools/bin
export PATH="$PATH:/opt/mssql-tools/bin"
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /etc/environment
source /etc/environment
echo $PATH
which sqlcmd
which bcp
sqlcmd -S localhost -U SA -p $sa_password -Q "CREATE DATABASE DRMONITORA"
clear
echo 'Microsoft SQL Server 2022 instalado com sucesso.'
