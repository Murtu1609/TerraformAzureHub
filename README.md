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
7) User assigned identity assigned to the VMs
8) Storage account for boot diagnostics
9) Keyvault that stores the linux public key and a random generated windows password
10) Log analytics workspace
11) Optional Bastion Host
12) Optional VPN Gateway and optional OpenVPN Client
13) Optional firewall, and firewall network and NAT rules using csv files
14) Optional recovery vault and backup policy to be assigned to each VM

# Pre requisites
1) Azure account and subcription id
2) A public and private key pair to be used for linux machines, this can be generated via the azure portal by creating the SSH Key resource
3) A resource Group with images for the VM builds
3) If using the optional OpenVPN Client, you will need to obtain a certificate .cer file

below url contains instructions for self signed cert on windows 10 

https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site

below url contains instructions to configure the OpenVPN Client

https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-openvpn-clients

# CSV Files description
create your csv files as per the examples linuxvms.csv, windowsvm.csv, sgrules.csv, fwnwrules.csv and fwnatrules.csv, or download the .zip ones, and edit them as per your requirements

1) The sgrules.csv file

fill any one of the sourceaddress, sourceaddresses or sourceasg columns, and put na in the other two

fill any one of the destaddress, destaddresses or destasg columns and put na in the other two

use sourceadresses and destadresses columns when you need to define multiple ipaddresses, and seperate each using a ;

provide an nsg name that you have mentioned in the variables (exampe usage below)



2) The windowsvms.csv and linuxvms.csv files

The avsets you mention in the avset column will be created and assigned to the VMs, you can assign the same avset to multiple vms.

Use the asgs and subnet names you mention in the variables (example usage below), for the asg,asg2,asg3 and subnet columns.

each VM can have upto 3 asgs, use na in the asg columns where you do not want an asg assigned

use na for the ip column if ipalloc column is dynamic



3) The fwnwrules.csv file

You can have multipe rules in a collection by repeating the same collection name in the collectionname column,

all rulenames should be unique

you can have multiple sourceadresses, destadresses, destports and protocols, seperate them using a ;


4) The fwnatrules.csv

You can have multipe rules in a collection by repeating the same collection name in the collectionname column,

all rulenames should be unique

you can have multiple sourceadresses and protocols, seperate them using a ;

action column must be Dnat

# Example

you may use the below provider block or create your own

copy below code into a .tf file, edit the variables and csv files as per your requirement and run terraform init, terraform validate and terraform apply

```
provider "azurerm" {
  subscription_id = "your subscriptionid"
  
    features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

module "hub" {

source = "github.com/Murtu1609/TerraformAzureHub"

#Resource group to be created
resourcegroupname     = "AZExampleHub"
resourcegrouplocation = "West Europe"

#address space for the VNet, Vnet name will be the same as the resourcegroupname
addressspace = ["10.10.0.0/16"]

/* multiple subnets with their corresponding address spaces and security groups to be created.
   different or same security groups can be assigned to each subnet */
subnets = [
  { name = "subnet1", address = "10.10.1.0/24", sg = "sg1" },
  { name = "subnet2", address = "10.10.2.0/24", sg = "sg2" },
  { name = "subnet3", address = "10.10.3.0/24", sg = "sg2" },
]

#list of application security groups to be created
asgs = ["asg1", "asg2", "asg3"]

/*paths of csv files containing security group rules, windows and linux vm details, 
if you do not wish to create any of them, delete all rows except for the first title row
you need to have a private and public key pair, paste the public key in a txt file and provide its path,
use the private key to access the linux machines */
sgrulespath = "D:/AzureTerraform/AZTF/hub3/csvfiles/sgrules.csv"
windowsvmpath = "D:/AzureTerraform/AZTF/hub3/csvfiles/windowsvms.csv"
linuxvmpath = "D:/AzureTerraform/AZTF/hub3/csvfiles/linuxvms.csv"
publickeypath = "D:/AzureTerraform/AZTF/hub3/publickey.txt"

#AzureADGroupname which will have access to the keyvault containing the windowspassword
keyvaultgroup = "keyvaultaccessgroup"

#details for optional bastion host
bastion              = "true"
bastionsubnetaddress = "10.10.5.0/24"

#details for optional VPN Gateway and OpenVPN client, you need to provide the path for the vpn cert .cer file
vpngw         = "true"
gwaddress     = "10.10.6.0/24"
vpnclient     = "true"
clientaddress = ["192.168.2.0/24"]
vpncertname   = "selfsigned"
vpncertpath   = "D:/AzureTerraform/AZTF/hub3/vpncert.cer"

#Details for optional firewall
firewall  = "true"
fwaddress = "10.10.7.0/24"
networkrulespath = "D:/AzureTerraform/AZTF/hub3/csvfiles/fwnwrules.csv"
natrulespath = "D:/AzureTerraform/AZTF/hub3/csvfiles/fwnatrules.csv"

#Details for optional recovery vault and backup policy that will be assigned to each VM
recoveryvault = "true"
backuppolicy = {
  name      = "bpol",
  timezone  = "UTC",
  frequency = "Daily",
  time      = "23:00",
#optional: use "na" for count if not required
  dailyretentioncount = 10,
#optional: use "na" for count if not required
  weeklyretentioncount = 42,
  wdays                = ["Sunday", "Wednesday", "Friday", "Saturday"],
#optional: use "na" for count if not required
  monthlyretentioncount = 7,
  mdays                 = ["Sunday", "Wednesday"],
  mweeks                = ["First", "Last"]
#optional: use "na" for count if not required
  yearlyretentioncount = "na"
  ydays                = ["Sunday"]
  yweeks               = ["Last"]
  ymonths              = ["January"]
}

#Tags for all resources 
tags = {
  owner         = "Murtuza"
  business_unit = "Test"
  costcode      = 314159
  downtime      = "03:30 - 04:30"
  env           = "training"
  enforce       = false
}
}
```

