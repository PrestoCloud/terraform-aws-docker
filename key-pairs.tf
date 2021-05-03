resource "aws_key_pair" "deployer" {
  key_name   = "deploy"
  public_key = file("${path.module}/../.ssh/id_rsa.pub")
}

