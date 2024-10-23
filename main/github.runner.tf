resource "aws_instance" "github_runner" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.nano"
  user_data = base64encode(templatefile("${path.module}/scripts/github-runner-setup.sh", {
    github_token = local.github_token,
    runner_label = local.runner_label,
    repo_url     = local.repo_url
  }))

  associate_public_ip_address = true
  key_name = aws_key_pair.github_runner_key.key_name

  subnet_id     = aws_subnet.main[0].id
  vpc_security_group_ids = [aws_security_group.github_runner_sg.id]

  tags = {
    Name = "${local.prefix}-github-runner"
  }
}


resource "aws_security_group" "github_runner_sg" {
  name        = "${local.prefix}-github-runner-sg"
  description = "Security group for GitHub runner"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.openvpn_sg.id]
    description = "Allow SSH from OpenVPN"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.prefix}-github-runner-sg"
  }
}

resource "aws_key_pair" "github_runner_key" {
  key_name   = "${local.prefix}-github-runner-key"
  public_key = local.github_public_key
}

