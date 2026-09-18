## // Security Groups

resource "ibm_is_security_group" "pub_sg" {
  name = "${var.prefix}-pub-sg"

  vpc            = var.vpc_id
  resource_group = var.resource_group_id
}

resource "ibm_is_security_group" "pri_sg" {
  name = "${var.prefix}-pri-sg"

  vpc            = var.vpc_id
  resource_group = var.resource_group_id
}

## // Security Group Rules

## // Pub
resource "ibm_is_security_group_rule" "pub-sg-rule-ssh" {
  group     = ibm_is_security_group.pub_sg.id
  direction = "inbound"
  remote    = "49.37.161.23/32"
  protocol  = "tcp"
  port_min  = 22
  port_max  = 22
}

resource "ibm_is_security_group_rule" "pub-sg-rule-jump" {
  group     = ibm_is_security_group.pub_sg.id
  direction = "inbound"
  remote    = "162.133.135.229/32"
  protocol  = "tcp"
  port_min  = 22
  port_max  = 22
}

resource "ibm_is_security_group_rule" "pub-sg-http" {
  group     = ibm_is_security_group.pub_sg.id
  direction = "inbound"
  remote    = "49.37.161.23/32"
  protocol  = "tcp"
  port_min  = 80
  port_max  = 80
}

resource "ibm_is_security_group_rule" "pub_outbound" {
  group     = ibm_is_security_group.pub_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

## // Pri
resource "ibm_is_security_group_rule" "pri_from_pub_sg" {
  group     = ibm_is_security_group.pri_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.pub_sg.id
}

resource "ibm_is_security_group_rule" "pri_outbound" {
  group     = ibm_is_security_group.pri_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}