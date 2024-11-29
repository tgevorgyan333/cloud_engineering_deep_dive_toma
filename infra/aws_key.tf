resource "aws_key_pair" "core_instance_access" {
  key_name   = "dev_core_instance_access"
  public_key = file("${path.module}/pub_keys/dev_core_instance_access.pub")
  tags = {
    Name = "dev_core_instance_access"
  }
}
