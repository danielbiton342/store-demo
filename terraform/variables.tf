variable "resource_group" {
  type    = string
  default = "terraform-test"
}

variable "rg-location" {
  type    = string
  default = "westeurope"
}


variable "object_id" {
  type      = string
  sensitive = true
}

variable "sshkey" {
  type        = string
  sensitive   = true
  description = "ssh key of my own local id_rsa.pub integrated on aks cluster"
}


variable "dns_prefix" {
  type    = string
  default = "myAKSClust-aks-store-demo-a20b8a"
}
