#!/bin/sh

# mkdir /root/late
# cp /cdrom/preseed/ipmicfg /target/root/late
# cp /cdrom/preseed/late.sh /target/root/late

LOG="/root/late/late.log"
IPMICFG="/root/late/ipmicfg"

# set hostname with serial numbers
sn=`${IPMICFG} -fru PS`
echo "sn: ${sn}" >> ${LOG} 2>&1
board_sn=`cat /sys/devices/virtual/dmi/id/board_serial`
echo "board_sn: ${board_sn}" >> ${LOG} 2>&1
hostname="UBUNTU-16046-TB-NVME-${board_sn}-${sn}"
echo "hostname: ${hostname}" >> ${LOG} 2>&1
echo "${hostname}" > /etc/hostname
echo "${sn}" > /etc/sn
echo "${board_sn}" >> /etc/sn

# update grub
sed -i 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' /etc/default/grub >> ${LOG} 2>&1
update-grub >> ${LOG} 2>&1

