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
7) Optional Bastion Host
8) Optional VPN Gateway and optional OpenVPN Client
9) Optional firewall, and firewall network and NAT rules using csv files
10) Optional recovery vault and backup policy to be assigned to each VM
