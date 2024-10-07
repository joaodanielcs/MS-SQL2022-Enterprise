#!/bin/bash

read -sp 'Enter the SQL Server system administrator password: ' sa_password
echo
apt install nala sudo -y
clear
nala update
nala upgrade -y
sudo nala install gnupg2 apt-transport-https wget curl ufw neofetch expect -y
bash -c 'echo -e "clear\nneofetch --title_fqdn on --memory_unit gib --memory_percent on --speed_shorthand on --cpu_temp C\nsystemctl list-units --type service | egrep '\''apache2|SQL|ssh'\''" > /etc/profile.d/mymotd.sh && chmod +x /etc/profile.d/mymotd.sh'
neofetch
clear
sed -i 's/# info "Local IP" local_ip/info underline\n    info "Local IP" local_ip/' .config/neofetch/config.conf
sed -i 's/# info "Public IP" public_ip/info "Public IP" public_ip/' .config/neofetch/config.conf
sudo echo 'alias neofetch="neofetch --title_fqdn on --memory_unit gib --memory_percent on --speed_shorthand on --cpu_temp C"' >> ~/.bashrc
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
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /etc/environment
echo 'alias neofetch="neofetch --title_fqdn on --memory_unit gib --memory_percent on --speed_shorthand on --cpu_temp C"' >> /etc/environment
source /etc/environment
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.profile
echo 'alias neofetch="neofetch --title_fqdn on --memory_unit gib --memory_percent on --speed_shorthand on --cpu_temp C"' >> ~/.profile
source ~/.profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
echo 'alias neofetch="neofetch --title_fqdn on --memory_unit gib --memory_percent on --speed_shorthand on --cpu_temp C"' >> ~/.bashrc
source ~/.bashrc

echo $PATH
which sqlcmd
which bcp
sqlcmd -S localhost -U sa -P $sa_password -Q "CREATE DATABASE DRMONITORA"
clear
neofetch --title_fqdn on --memory_unit gib --memory_percent on --speed_shorthand on --cpu_temp C
echo '
   Microsoft SQL Server 2022 instalado com sucesso.
'
