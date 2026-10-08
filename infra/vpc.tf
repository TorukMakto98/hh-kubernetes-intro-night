# The VPC already exists (created manually); only look it up.
data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnets" "existing" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

# The VPC's main route table, used by the node subnets.
data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.existing.id

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

# The original internet gateway was deleted, which left the default route blackholed.
# Nodes need this route to pull images from ghcr.io and other registries.
resource "aws_internet_gateway" "main" {
  vpc_id = data.aws_vpc.existing.id
}

resource "aws_route" "internet" {
  route_table_id         = data.aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
