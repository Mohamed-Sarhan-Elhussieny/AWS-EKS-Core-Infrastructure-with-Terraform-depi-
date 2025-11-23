

# ************************* aws_vpc ****************************************#

# Create a VPC
resource "aws_vpc" "vpc_depi" {
  cidr_block = "10.0.0.0/16"

    tags = {
    Name = "vpc-depi"
  }
}

#************************* aws_subnet ****************************************#

resource "aws_subnet" "subnet_depi_public1" {
  vpc_id                  = aws_vpc.vpc_depi.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true  # to give created node ip

  tags = {
    Name = "subnet-public1"
  }
}

resource "aws_subnet" "subnet_depi_public2" {
  vpc_id                  = aws_vpc.vpc_depi.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true 

  tags = {
    Name = "subnet-public2"
  }
}

resource "aws_subnet" "subnet_depi_public3" {
  vpc_id                  = aws_vpc.vpc_depi.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true  

  tags = {
    Name = "subnet-public3"
  }
}


# #************************* aws_internet_gateway ****************************************#


resource "aws_internet_gateway" "gateway_depi" {
  vpc_id = aws_vpc.vpc_depi.id

  tags = {
    Name = "gateway-depi"
  }
}

# #************************* aws_route_table ****************************************#

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc_depi.id

  tags = {
    Name = "rt-public"
  }
}



# #************************* aws_route_table_association ****************************************#


resource "aws_route_table_association" "route_associate1" {
  subnet_id      = aws_subnet.subnet_depi_public1.id
  route_table_id = aws_route_table.rt_public.id
}


resource "aws_route_table_association" "route_associate2" {
  subnet_id      = aws_subnet.subnet_depi_public2.id
  route_table_id = aws_route_table.rt_public.id
}


resource "aws_route_table_association" "route_associate3" {
  subnet_id      = aws_subnet.subnet_depi_public3.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route" "route_associate_igw" {
  route_table_id            = aws_route_table.rt_public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id =aws_internet_gateway.gateway_depi.id
}
