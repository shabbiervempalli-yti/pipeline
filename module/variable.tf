variable "resourcegroup" {
  default = "ydx-msa-infra-rg"
}
variable "subnet" {
  default = "ydx-msa-subnet"
}
variable "vmsize" {
  default = "Standard_B2ms"
}
variable "nsg_name" {
  default = "POSTGRES-NSG"
}
variable "zone" {
  default = "1"
}
variable "zones" {
  type  = list(string)
  default = ["1"]
  
}
variable "osdisk" {
  default = "30"
}

variable "disksize" {
  default = "64"
}
variable "vnet" {
  default = "ydx-msa-vnet"
}

variable "location"{
  default = "Southeast Asia"
}

variable "username"{
  default = ""
}
variable "password"{
  default = ""
}

variable "vm_name" {
  type  = list(string)
  default = ["master-postgres"]
}

