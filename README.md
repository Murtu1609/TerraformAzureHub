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

1) The sgrules.csv file

you need to fill any one from sourceaddress, sourceaddresses and sourceasg, and put na in the other two

you need to fill any one from destaddress, destaddresses and destasg, and put na in the other two

use sourceadresses and destadresses when you need to define multiple ipaddresses, and seperate each using a ;

provide an nsg name that you have mentioned in the variables (exampe usage below)



2) windowsvms.csv and linuxvms.csv files

the avsets you mention will be created and assigned to the VMs, you can assign the same avset to multiple vms.

you need to use the asgs and subnet names you mention in the variables (example usage below).

each VM can have upto 3 asgs, use na in the asg columns where you do not want an asg assigned

use na for ip if ipalloc is dynamic



3) the fwnwrules.csv file

you can have multipe rules in a collection by repeating the same collection name,

all rulenames should be unique

you can have multiple sourceadresses, destadresses, destports and protocols, seperate them using a ;




