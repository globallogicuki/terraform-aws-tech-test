variable "region" {
}

variable "vpc-cidr" {
}

variable "subnet-cidr-public-01" {
}

variable "subnet-cidr-public-02" {
}

variable "subnet-cidr-private-01" {
}

variable "subnet-cidr-private-02" {
}

variable "vpc" {
}

variable "Owner" {
}

variable "Project" {
}


# for the purpose of this exercise use the default key pair on your local system
variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}


