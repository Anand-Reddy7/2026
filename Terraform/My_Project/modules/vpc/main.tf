# // Create a VPC
resource "ibm_is_vpc" "main" {
  name                      = "${var.prefix}-vpc"
  resource_group            = var.resource_group_id
  address_prefix_management = "manual"
}

resource "ibm_is_vpc_address_prefix" "main-pub-prefix" {
  name = "${var.prefix}-vpc-pub-address-prefix"
  vpc  = ibm_is_vpc.main.id
  zone = "${var.region}-1"
  cidr = "10.20.0.0/21"
}

resource "ibm_is_vpc_address_prefix" "main-pri-prefix" {
  name = "${var.prefix}-vpc-pri-address-prefix"
  vpc  = ibm_is_vpc.main.id
  zone = "${var.region}-2"
  cidr = "10.20.32.0/19"
}
## // Create Public Gateway

resource "ibm_is_public_gateway" "pub_gateway" {
  name           = "${var.prefix}-pg"
  vpc            = ibm_is_vpc.main.id
  zone           = "${var.region}-1"
  resource_group = var.resource_group_id
}


## // Subnets
resource "ibm_is_subnet" "pub_subnet" {
  name           = "${var.prefix}-pub-subnet"
  resource_group = var.resource_group_id

  vpc             = ibm_is_vpc.main.id
  zone            = "${var.region}-1"
  ipv4_cidr_block = "10.20.0.0/21"

  public_gateway = ibm_is_public_gateway.pub_gateway.id

  depends_on = [ibm_is_vpc_address_prefix.main-pub-prefix]
}


resource "ibm_is_subnet" "pri_subnet" {
  name           = "${var.prefix}-pri-subnet"
  resource_group = var.resource_group_id

  vpc             = ibm_is_vpc.main.id
  zone            = "${var.region}-2"
  ipv4_cidr_block = "10.20.32.0/19"

  depends_on = [ibm_is_vpc_address_prefix.main-pri-prefix]
}