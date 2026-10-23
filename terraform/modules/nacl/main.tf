locals {
  tags = merge(
    {
      Environment = var.environment
      Project     = "cafe-platform"
      Terraform   = "true"
    },
    var.tags
  )

  # ---------------- Public subnets ----------------
  public_ingress = merge(
    {
      http      = { rule = 100, cidr = "0.0.0.0/0", from = 80, to = 80 }
      https     = { rule = 110, cidr = "0.0.0.0/0", from = 443, to = 443 }
      ephemeral = { rule = 200, cidr = "0.0.0.0/0", from = 1024, to = 65535 } # replies to outbound requests
    },
    { for i, c in var.ssh_allowed_cidrs :
      "ssh-${i}" => { rule = 120 + i, cidr = c, from = 22, to = 22 }
    }
  )

  public_egress = merge(
    {
      http      = { rule = 100, cidr = "0.0.0.0/0", from = 80, to = 80 }   # dnf repos
      https     = { rule = 110, cidr = "0.0.0.0/0", from = 443, to = 443 } # SSM, downloads
      ephemeral = { rule = 200, cidr = "0.0.0.0/0", from = 1024, to = 65535 } # replies to browser/SSH
    },
    { for i, c in var.private_subnet_cidrs :
      "db-${i}" => { rule = 120 + i, cidr = c, from = var.db_port, to = var.db_port }
    }
  )

  # ---------------- Private subnets ----------------
  private_ingress = { for i, c in var.public_subnet_cidrs :
    "db-${i}" => { rule = 100 + i, cidr = c, from = var.db_port, to = var.db_port }
  }

  private_egress = { for i, c in var.public_subnet_cidrs :
    "ephemeral-${i}" => { rule = 100 + i, cidr = c, from = 1024, to = 65535 }
  }
}

# ===================== PUBLIC =====================
resource "aws_network_acl" "public" {
  vpc_id     = var.vpc_id
  subnet_ids = var.public_subnet_ids

  tags = merge(local.tags, { Name = "${var.name}-${var.environment}-public-nacl" })
}

resource "aws_network_acl_rule" "public_ingress" {
  for_each = local.public_ingress

  network_acl_id = aws_network_acl.public.id
  egress         = false
  rule_number    = each.value.rule
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = each.value.cidr
  from_port      = each.value.from
  to_port        = each.value.to
}

resource "aws_network_acl_rule" "public_egress" {
  for_each = local.public_egress

  network_acl_id = aws_network_acl.public.id
  egress         = true
  rule_number    = each.value.rule
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = each.value.cidr
  from_port      = each.value.from
  to_port        = each.value.to
}

# ===================== PRIVATE =====================
resource "aws_network_acl" "private" {
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  tags = merge(local.tags, { Name = "${var.name}-${var.environment}-private-nacl" })
}

resource "aws_network_acl_rule" "private_ingress" {
  for_each = local.private_ingress

  network_acl_id = aws_network_acl.private.id
  egress         = false
  rule_number    = each.value.rule
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = each.value.cidr
  from_port      = each.value.from
  to_port        = each.value.to
}

resource "aws_network_acl_rule" "private_egress" {
  for_each = local.private_egress

  network_acl_id = aws_network_acl.private.id
  egress         = true
  rule_number    = each.value.rule
  rule_action    = "allow"
  protocol       = "tcp"
  cidr_block     = each.value.cidr
  from_port      = each.value.from
  to_port        = each.value.to
}