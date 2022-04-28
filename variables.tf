// Variables
variable "aws_region" {
  type = string
  description = "The region in which the resources will be created"
  default = "us-east-1"
}

variable "ssh_pubkey_location" {
  type = string
  description = "ssh public key location"
  default = "/home/gk/.ssh/tf.pub"
}