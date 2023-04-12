variable = "region" {
    default = "ap-south-1"
}

variable = "vpc_cidr" {
    type = string
    description = "Enter the VPC Cidr value"
    default = "10.0.0.0/16"

}


variable = "sub_cidr1" {
        type = string
        description = "Enter the subnet1 Cidr value"
        default     = "10.0.2.0/24" 

}

variable = "sub_cidr1" {
        type = string
        description = "Enter the Subnet2 Cidr value"
        default     = "10.0.1.0/24"

}

variable = "azs-a" {
 type        = string
 description = "Availability Zones"
 default     = "ap-south-1a"
}

variable = "azs-b" {
 type        = string
 description = "Availability Zones"
 default     = "ap-south-1b"
}