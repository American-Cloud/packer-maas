#!/bin/bash -e
#
# customize.sh - Set up AC software changes
#

# Configure apt proxy if needed.
packer_apt_proxy_config="/etc/apt/apt.conf.d/packer-proxy.conf"
if  [ ! -z  "${http_proxy}" ]; then
  echo "Acquire::http::Proxy \"${http_proxy}\";" >> ${packer_apt_proxy_config}
fi
if  [ ! -z  "${https_proxy}" ]; then
  echo "Acquire::https::Proxy \"${https_proxy}\";" >> ${packer_apt_proxy_config}
fi


apt update -y 2>/dev/null
apt upgrade -y 2>/dev/null
wget -q -P /tmp "https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix/zabbix-agent_6.2.6-1%2Bubuntu22.04_amd64.deb"
apt install -f -y /tmp/zabbix-agent_6.2.6-1+ubuntu22.04_amd64.deb 2>/dev/null
apt install -y vim wget mtr netcat htop 2>/dev/null
#Install zabbix-agent
sed -i 's/Server=127.0.0.1/Server="ZABBIX_SERVER"/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server//' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive="ZABBIX_SERVER"/' /etc/zabbix/zabbix_agentd.conf
sed -i '/# HostMetadata=/aHostMetadata=\"Linux by Zabbix agent, Linux servers\"' /etc/zabbix/zabbix_agentd.conf
sed -i '/# HostMetadataItem=/aHostMetadataItem=system.hostname' /etc/zabbix/zabbix_agentd.conf
systemctl enable zabbix-agent

apt autoremove -y 2>/dev/null
apt clean -y 2>/dev/null
