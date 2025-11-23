resource "aws_ebs_volume" "esi_Volume" {
  availability_zone = "us-east-1c"
  size              = 10
  type              = "gp3"

  tags = {
    Name = "Volumes-esi"
  }
}


