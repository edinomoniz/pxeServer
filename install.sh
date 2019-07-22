#!/bin/bash
# File     : ud-pxeserver
# Created  : <2019-05-18 Sat 15:21:00 BST>
# Modified : <2019-15-18 Sat 21:23:00 GMT> edinomoniz
# 
#
#+----------------------------------------------------------------------------------------------------+
# We will need to change the IP's to match the ones for the server on the following files
# /library/tftpboot/pxelinux.cfg/ubuntu-server.cfg
# /etc/dnsmasq.conf # to match the network range
#
# When installing on VM's, we need to edit the the tb-mt-cli-16.04.cfg file, and change the sda -> vda,
# or we will get an error at the auto-partitioning
#
#+----------------------------------------------------------------------------------------------------+
# TO-DO List
#
# Add option to choose :
#     desired IP address and Netmask for eth1
#     Installation options:
#         - 1: Virtual Machine
#         - 2: Physical Server

#
#+----------------------------------------------------------------------------------------------------+


ud_lib=/library
ud_tftp=/library/tftpboot
ud_www=/library/www

# Updates the system packages and installs #syslinux, #dnsmasq, #apache2
_up-inst(){
    apt update -y && apt upgrade -y && apt dist-upgrade -y
    apt install pxelinux syslinux dnsmasq apache2
}
_up-inst

# Grub and interfaces set for default configuration 
#_ifacesCfg(){

sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="net.ifnames=0 biosdevname=0"/' /etc/default/grub
sed -i 's/ens3/eth0/g' /etc/network/interfaces
cat >> /etc/network/interfaces <<EOF

# The PXE Lan Interface
auto eth1
iface eth1 inet static
    address 192.168.1.1
    netmask 255.255.255.0
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
EOF
#}
#_ifacesCfg

update-grub

# dnsmasq configuration
# Need to investigate why this function do not work with "cat >> file <<EOF"
#_dnsCfg(){
# Add to the DNSmasq.conf
cat >> /etc/dnsmasq.conf <<EOF
    interface=eth1,lo
    bind-interfaces
    domain=ud-pxeserver.man

    dhcp-range=eth1,192.168.1.30,192.168.1.253,255.255.255.0,1h
    dhcp-option=3,192.168.1.1
    dhcp-option=6,8.8.8.8
    server=8.8.4.4
    dhcp-option=42,0.0.0.0

    dhcp-boot=pxelinux.0,pxeserver,192.168.1.1

    port=0
    log-dhcp
    dhcp-range=192.168.1.0,proxy
    dhcp-boot=pxelinux.0
    pxe-service=x86PC,'ud-pxeboot-server',pxelinux
    enable-tftp
    tftp-root=/library/tftpboot
EOF

#}
#_dnsCfg

echo "DNSMASQ_EXCEPT=lo" >> /etc/default/dnsmasq
sleep 5


# Library structure creation and necessary modules copy. 
mkdir -p $ud_www/html/preseed/
mkdir -p $ud_tftp/{pxelinux.cfg,ubuntu-16.04}

_copy-boot(){
    cp /usr/lib/PXELINUX/pxelinux.0 $ud_tftp
    cp /usr/lib/syslinux/modules/bios/{menu,ldlinux,libmenu,libutil}.c32 $ud_tftp
}
_copy-boot

_preseed(){
    cp -P cfg/{default,ubuntu-server.cfg} $ud_tftp/pxelinux.cfg/
    
    # Uncomment Use this line if installing in a physical equipment 
    cp cfg/preseed/tb-mt-cli-16.04.cfg $ud_lib/www/html/preseed/
    cp -r cfg/16046-tb-nvme/ /library/www/html/preseed/
    #cp -P cfg/preseed/tb-mt-cli-16.04_vm.cfg $ud_www/html/preseed/
    
    cp -r netboot/* $ud_tftp/ubuntu-16.04/
    
    # Still Implementing for TMS's with Ubuntu 12 and 16.
    # cp cfg/preseed/tms2-1* $ud_lib/www/html/preseed/

}
_preseed

_apache(){
    mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.backup
    mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.backup
    # Change with cat >> file <<EOF

    cp -r cfg/apache2.conf /etc/apache2/
    cp -r cfg/sites-available/000-default.conf /etc/apache2/sites-available/
    #ln -s /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf
}
_apache

sudo ufw allow 67/udp
sudo ufw reload


sudo systemctl net.ipv4.forwarding
sudo sysctl net.ipv4.ip_forward
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl net.ipv4.ip_forward
# ------------------------------------------------------------------------------
#+MAIN
# Use main instead of calling functions right after defining them, it is better codding practice. 
#main()
#{
#    _up-install
#    _copy-boot
#    _preseed
#    _apache
#    printf "Start %s %sv at %s\n\n" "\$CMDNAME" "\$CMD_VER" "\$(date)"
#    chk_require "\${REQUIRE[*]}"
#
#    ABS_PATH="\$(dirname "\$(readlink -f "\$0")")"
#`    echo "\$ABS_PATH"
#}
#
#main "\$@"

#systemctl restart apache2 networking.service dnsmasq
reboot
