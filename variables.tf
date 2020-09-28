


variable resourcegroupname {
  type    = string
  default = "SSPPHubTest"
}

variable resourcegrouplocation {
  type    = string
  default = "West Europe"
}

variable addressspace {

  default = ["10.0.0.0/16"]
}

variable subnets {

}

variable asgs {

}


variable bastionsubnet {
  type    = string

}

variable vpngw {
  type = bool
}
variable gwsubnet {
  type = string
}

variable vpnclient {
  type = bool
}

variable clientaddress {

}

variable vpncertname {
  type = string
}

variable vpncertpath {
  type = string
}


variable firewall {
  type = bool
}

variable fwsubnet {
  type = string
}

variable bastion {
  type = bool
}

variable recoveryvault {
  type = bool
}

variable backuppolicy {
  default = {
    name                  = "default",
    timezone              = "UTC",
    frequency             = "Daily",
    time                  = "23:00",
    dailyretentioncount   = 10,
    weeklyretentioncount  = 42,
    wdays                 = ["Sunday", "Wednesday", "Friday", "Saturday"],
    monthlyretentioncount = 7,
    mdays                 = ["Sunday", "Wednesday"],
    mweeks                = ["First", "Last"]
    yearlyretentioncount  = 77
    ydays                 = ["Sunday"]
    yweeks                = ["Last"]
    ymonths               = ["January"]
  }

}


variable "tags" {
  type = object({
    owner         = string
    business_unit = string
    costcode      = number
    downtime      = string
    env           = string
    enforce       = bool
  })
  default = {
    owner         = null
    business_unit = null
    costcode      = null
    downtime      = null
    env           = null
    enforce       = null
  }
}

variable "keyvaultgroup"{
type = string
}

variable "windowsvmpath" {
type = string
}

variable "linuxvmpath" {
type = string
}

variable "sgrulespath" {
type = string
}

variable "networkrulespath" {
type = string
}

variable "natrulespath" {
type = string
}

variable "publickeypath" {
type = string
}

variable "vpnmultiaz" {

}

variable "vpnsku" {

}

variable "createdomain" {
type = bool
}

variable "templatefilepath" {

}

variable "domainname" {

}

variable "domainsubnet" {

}

variable "filteredsync" {

}