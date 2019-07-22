# File     : README.md
# Created  : <2019-05-11 Sat 15:21:00 BST >
# Modified : <2019-15-18 Sat 21:23:00 BST> anakin "edino moniz"
#
#+--------------------------------------------------------------------------------------------
# New PXE Server installation
# For use in VM, there are some IP changes that need to be done on a physical 
# server in order for this script to work properlly
# Please note that for this case a 2nd network interface was added in the VM Management tool,
# eth1 is being used as the PXE Lan interface and it was attributed the IP: 192.168.42.11. 
# for a different range you will need to change the IP's for the following files:
# :::: /etc/dnsmasq.conf
# :::: /etc/network/interfaces
# :::: /library/tftpboot/pxelinux.cfg/ubuntu-server.cfg

# copy the folter the next to be pxe-server using ssh and as rot run the install.sh 
# after reboot the pxe-server will be ready to use.

requirements
vda = 15GB
 
