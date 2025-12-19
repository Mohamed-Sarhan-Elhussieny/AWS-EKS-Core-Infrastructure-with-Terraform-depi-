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
resource "aws_subnet" "subnet_depi_private1" {
  vpc_id                  = aws_vpc.vpc_depi.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "subnet-private1"
  }
}
resource "aws_subnet" "subnet_depi_private2" {
  vpc_id                  = aws_vpc.vpc_depi.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "subnet-private2"
  }
}
#************************* aws_route_table-public ****************************************#

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc_depi.id

  tags = {
    Name = "rt-public"
  }
}


#************************* aws_route_table-private ****************************************#

resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.vpc_depi.id

    route {
    cidr_block           = "0.0.0.0/0"
    nat_gateway_id=aws_nat_gateway.NAT_GW.id
  }

  tags = {
    Name = "rt-private"
  }
}
#************************* aws_route_table_association ****************************************#


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
#************************* aws_route_table_association-private ****************************************#

resource "aws_route_table_association" "route_associate_private1" {
  subnet_id      = aws_subnet.subnet_depi_private1.id
  route_table_id = aws_route_table.rt_private.id
}
resource "aws_route_table_association" "route_associate_private2" {
  subnet_id      = aws_subnet.subnet_depi_private2.id
  route_table_id = aws_route_table.rt_private.id
}
#************************* Elastic IP ****************************************#

resource "aws_eip" "NAT_EIP" {
  domain = "vpc"

  tags = {
    Name = "nat-gateway-eip"
  }

  depends_on = [aws_internet_gateway.gateway_depi]
}
#************************* aws_NAT_gateway ****************************************#


resource "aws_nat_gateway" "NAT_GW" {
  allocation_id = aws_eip.NAT_EIP.id
  subnet_id     = aws_subnet.subnet_depi_public1.id

  tags = {
    Name = "gw-NAT"
  }

  depends_on = [aws_internet_gateway.gateway_depi]
}


# #************************* aws_internet_gateway ****************************************#


resource "aws_internet_gateway" "gateway_depi" {
  vpc_id = aws_vpc.vpc_depi.id

  tags = {
    Name = "gateway-depi"
  }
}
resource "aws_route" "route_associate_igw" {
  route_table_id            = aws_route_table.rt_public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id =aws_internet_gateway.gateway_depi.id
}

