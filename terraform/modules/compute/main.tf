data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  count = length(var.subnet_ids)

  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_ids[count.index]
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = true

  metadata_options {
    http_tokens = "required" # IMDSv2
  }

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp2"
  }

  tags = merge(
    {
      Name        = "${var.name}-${var.environment}-web-${count.index + 1}"
      Environment = var.environment
      Project     = "cafe-platform"
      Role        = "web"
      Terraform   = "true"
    },
    var.tags
  )
}