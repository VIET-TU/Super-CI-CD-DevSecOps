variable "instance_type" {
  type = string
  description = "Instance type of the EC2"

  validation {
    condition = contains(["t2.micro", "t2.small"], var.instance_type)
    error_message = "Value not allow."
  }
}

variable "ami_id" {
   type = string
}

variable "subnet_id" {
   type = string
}

variable "hosted_zone_id" {
   type = string
}