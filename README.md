# TerraformAzureHub
A dynamic Terraform module to create a network and compute resources in Azure

# Description
This module creates the below resources
1) Resource Group
2) VNet
3) Subnets with associated Security Groups
4) Security Group Rules using a csv file
5) Application security groups
6) Windows and Linux VM's using csv files
7) Storage account for boot diagnostics
8) Keyvault that stores the linux public key and a random generated windows password
9) Log analytics workspace
10) Optional Bastion Host
11) Optional VPN Gateway and optional OpenVPN Client
12) Optional firewall, and firewall network and NAT rules using csv files
13) Optional recovery vault and backup policy to be assigned to each VM

# Pre requisites
1) Azure account and subcription id
2) A public and private key pair to be use for linux machines, this can be generated via the azure console by creating the SSH Key resource
3) A resource Group with images for the VM builds
3) If using the OpenVPN Client, you will need to obtain a certificate .cer file
below url contains instructions for self signed cert on windows 10 
https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site
below url contains instructions to configure the OpenVPN Client
https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-openvpn-clients

# CSV Files description
you need to download the csv files from this page and edit them as per your requirements

The sgrules.csv file contains the following columns

name	priority	direction	access	protocol	sourceport	destinationport	sourceaddress	destaddress	sourceaddresses	           destaddresses	sourceasg	destasg	nsg

sg2rule1	100	  inbound	  allow  	tcp	        *	           22	               na          	*	    192.168.2.0/24;192.168.1.0/24	na	            na	      na	sg2

you need to fill any one from sourceaddress, sourceaddresses and sourceasg, and put na in the other two
you need to fill any one from destaddress, destaddresses and destasg, and put na in the other two
use sourceadresses and destadresses when you need to define multiple ipaddresses, and seperate each using a ;
provide an nsg name that you have mentioned in the variables (exampe usage below)


the windowsvms.csv and linuxvms.csv files contain the below columns
adminuser	name	        ipalloc	    ip	        imagename	     imagerg	  size	      subnet	avset	  asg	asg2	asg3
zadmin	windowsexample1	static	10.10.1.15	windows_server_base	images	Standard_B1ms	subnet1	avset1	asg1	asg2	asg3
zadmin	windowsexample2	dynamic	   na      	windows_server_base	images	Standard_B1ms	subnet2	avset2	asg1	asg2	na
zadmin	windowsexample3	dynamic	   na	      windows_server_base	images	Standard_B1ms	subnet3	avset2	asg1	na	na

the avsets you mention will be created and assigned to the VMs, you can assign the same avset to multiple vms.
you need to use the asgs and subnet names you mention in the variables (example usage below).
each VM can have upto 3 asgs, use na in the asg columns where you do not want an asg assigned
use na for ip if ipalloc is dynamic


the fwnwrules.csv contains the below columns
collectionname	priority	action	rulename	sourceaddresses	                destaddresses	           destports	protocols
fwrules1	      100	     Allow	rules1rule1	192.168.2.0/24;192.168.3.0/24	 10.10.1.0/24;10.10.2.0/24	3389;22  	TCP
fwrules1	      100	     Allow	rules1rue2	192.168.3.0/24;192.168.4.0/24	 10.10.3.0/24;10.10.4.0/24	3389;22  	TCP
fwrules2	      110	     Allow	rules2rule1	192.168.2.0/24	               10.10.1.0/24	              8080	    TCP;UDP
fwrules2       	110	     Allow	rules2rule2	192.168.5.0/24                 10.10.100.0/24	           8080	    TCP;UDP

you can have multipe rules in a collection by repeating the same collection name,
all rulenames should be unique
you can have multiple sourceadresses, destadresses, destports and protocols, seperate them using a ;




