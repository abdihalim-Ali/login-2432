# Volume
resource "aws_ebs_volume" "vol" {
  availability_zone = var.zone
  size              = var.size

  tags = {
    Name = "${var.vol_name}"
  }
}