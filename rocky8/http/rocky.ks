url --url="https://download.rockylinux.org/pub/rocky/8/BaseOS/x86_64/os/"
url --mirrorlist="http://mirrors.rockylinux.org/mirrorlist?arch=x86_64&repo=BaseOS-8"
repo --name="AppStream" --mirrorlist="https://mirrors.rockylinux.org/mirrorlist?release=8&arch=x86_64&repo=AppStream-8"
repo --name="Extras" --mirrorlist="https://mirrors.rockylinux.org/mirrorlist?arch=x86_64&repo=extras-8"

# Turn off after installation
poweroff
# Disable firewall
firewall --disable
# Do not start the Inital Setup app
firstboot --disable
# System language, keyboard and timezone
lang en_US.UTF-8
keyboard us
timezone UTC --utc
# Set the first NIC to acquire IPv4 address via DHCP
network --device eth0 --bootproto=dhcp
# Disable SELinux
selinux --disabled

eula --agreed

# Do not set up XX Window System
skipx

# Initial disk setup
# Use the first paravirtualized disk
ignoredisk --only-use=vda
# Place the bootloader on the Master Boot Record
bootloader --location=mbr --driveorder="vda" --timeout=1 --append="debug"
# Wipe invalid partition tables
zerombr
# Erase all partitions and assign default labels
clearpart --all --initlabel
# Initialize the primary root partition with ext4 filesystem
part / --size=1 --grow --asprimary --fstype=ext4

# Set root password
rootpw --plaintext password

%post --erroronfail
# SSH settings
sed -i -E 's/^(\s*#*)(\s*PermitRootLogin\s+)(.*)$/\2no/' /etc/ssh/sshd_config

sleep 10
dnf update -y
dnf upgrade -y
dnf install -y vim wget mtr nc
#Install zabbix-agent
dnf install -y https://repo.zabbix.com/zabbix/6.2/rhel/8/x86_64/zabbix-agent-6.2.6-release1.el8.x86_64.rpm
sed -i 's/Server=127.0.0.1/Server=ZABBIX_SERVER/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server//' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=ZABBIX_SERVER/' /etc/zabbix/zabbix_agentd.conf
sed -i '/# HostMetadata=/aHostMetadata=\"Linux by Zabbix agent, Linux servers\"' /etc/zabbix/zabbix_agentd.conf
sed -i '/# HostMetadataItem=/aHostMetadataItem=system.hostname' /etc/zabbix/zabbix_agentd.conf
systemctl enable zabbix-agent

dnf clean all
# workaround anaconda requirements and clear root password
passwd -d root
passwd -l root

# Clean up install config not applicable to deployed environments.
for f in resolv.conf fstab; do
    rm -f /etc/$f
    touch /etc/$f
    chown root:root /etc/$f
    chmod 644 /etc/$f
done

# remove ssh host keys
rm -f /etc/ssh/*key*

# remove authorized_keys files
rm -f /root/.ssh/authorized_keys
rm -f /home/*/.ssh/authorized_keys

# clean up logs
cat /dev/null > /var/log/audit/audit.log 2> /dev/null
rm -f /var/log/audit.log.* 2>/dev/null
cat /dev/null > /var/log/wtmp 2>/dev/null
logrotate -f /etc/logrotate.conf 2>/dev/null
rm -f /var/log/*.[0-9] /var/log/*.gz 2>/dev/null

# attempt to clean up history
history -c
unset HISTFILE

# unmap deleted blocks
fstrim -a -v

rm -f /etc/sysconfig/network-scripts/ifcfg-[^lo]*

# Kickstart copies install boot options. Serial is turned on for logging with
# Packer which disables console output. Disable it so console output is shown
# during deployments
sed -i 's/^GRUB_TERMINAL=.*/GRUB_TERMINAL_OUTPUT="console"/g' /etc/default/grub
sed -i '/GRUB_SERIAL_COMMAND="serial"/d' /etc/default/grub
sed -ri 's/(GRUB_CMDLINE_LINUX=".*)\s+console=ttyS0(.*")/\1\2/' /etc/default/grub

%end













%packages
@Core
bash-completion
cloud-init
cloud-utils-growpart
xfsprogs
rsync
tar
patch
yum-utils
grub2-efi-x64
shim-x64
grub2-efi-x64-modules
efibootmgr
dosfstools
lvm2
mdadm
device-mapper-multipath
iscsi-initiator-utils
-plymouth
# Remove ALSA firmware
-a*-firmware
# Remove Intel wireless firmware
-i*-firmware
%end