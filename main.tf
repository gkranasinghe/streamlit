module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # enable_nat_gateway = true
  # enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  
  name = "frontend"

  ami                    = data.aws_ami.ubuntu.image_id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.tf.key_name
  monitoring             = true
  vpc_security_group_ids = [module.frontend_sg.security_group_id]
  subnet_id = element(module.vpc.public_subnets, 0)
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
  depends_on = [
    module.frontend_sg
  ]
}

module "frontend_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "frontend-service"
  description = "Security group for frontend-service with ssh port open"
  vpc_id      = module.vpc.vpc_id
  # ingress_cidr_blocks      = ["10.10.0.0/16"]
  # ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    # {
    #   from_port   = 8080
    #   to_port     = 8090
    #   protocol    = "tcp"
    #   description = "User-service ports"
    #   cidr_blocks = "10.10.0.0/16"
    # },
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
    egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    },
    ]

  depends_on = [
    module.vpc
  ]
}
resource "aws_key_pair" "tf" {
  key_name   = "tf"
  public_key = data.local_file.ssh_key.content
}

data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}
data "local_file" "ssh_key" {
    filename = var.ssh_pubkey_location
}
