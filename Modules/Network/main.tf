# VPC Creation
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    { Name = "${var.project_name}-vpc" },
    { Project = var.project_name, Terraform = "true" }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    { Name = "${var.project_name}-igw" },
    { Project = var.project_name, Terraform = "true" }
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    { Name = "${var.project_name}-public-subnet-${var.availability_zones[count.index]}" },
    { Tier = "Public", Project = var.project_name, Terraform = "true" }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    { Name = "${var.project_name}-private-subnet-${var.availability_zones[count.index]}" },
    { Tier = "Private", Project = var.project_name, Terraform = "true" }
  )
}

# --- NAT Gateway Setup ---
# Create one NAT Gateway per AZ for high availability
resource "aws_eip" "nat" {
  count      = length(var.public_subnet_cidrs) # One EIP per public subnet/AZ
  # Use domain attribute for provider version >= 4.0, vpc for older
  # domain     = "vpc"
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    { Name = "${var.project_name}-nat-eip-${var.availability_zones[count.index]}" },
    { Project = var.project_name, Terraform = "true" }
  )
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet_cidrs) # One NAT GW per public subnet/AZ
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id # Place NAT GW in corresponding public subnet

  tags = merge(
    { Name = "${var.project_name}-nat-gw-${var.availability_zones[count.index]}" },
    { Project = var.project_name, Terraform = "true" }
  )

  depends_on = [aws_internet_gateway.igw]
}


# --- Route Tables ---

# Public Route Table (routes 0.0.0.0/0 to Internet Gateway)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    { Name = "${var.project_name}-public-rt" },
    { Project = var.project_name, Terraform = "true" }
  )
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables (one per AZ, routing 0.0.0.0/0 to corresponding NAT Gateway)
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = merge(
    { Name = "${var.project_name}-private-rt-${var.availability_zones[count.index]}" },
    { Project = var.project_name, Terraform = "true" }
  )
}

# Associate Private Subnets with their corresponding Private Route Table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
