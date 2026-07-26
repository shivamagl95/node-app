# ==================== Security Group ====================
resource "aws_security_group" "tools_server" {
  name        = "${terraform.workspace}-tools-server"
  description = "Security group for SonarQube + ELK server"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Restrict this in production!
    description = "SSH Access"
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SonarQube"
  }

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kibana"
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Elasticsearch (optional)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${terraform.workspace}-tools-server-sg"
    Environment = terraform.workspace
  }
}

# ==================== EC2 Instance ====================
resource "aws_instance" "tools_server" {
  ami                    = data.aws_ami.ubuntu_24_04.id
  instance_type          = "t3.large"       
  subnet_id              = data.aws_subnets.public.ids[0]
  vpc_security_group_ids = [aws_security_group.tools_server.id]
  key_name               = "${terraform.workspace}-key"
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              set -ex

              # Update system
              apt-get update -y
              apt-get upgrade -y

              # Install required packages
              apt-get install -y ca-certificates curl gnupg lsb-release jq

              # Install Docker
              install -m 0755 -d /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              chmod a+r /etc/apt/keyrings/docker.asc

              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                tee /etc/apt/sources.list.d/docker.list > /dev/null

              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

              # Start and enable Docker
              systemctl start docker
              systemctl enable docker

              # Add ubuntu user to docker group
              usermod -aG docker ubuntu

              # Install Docker Compose v2 (as plugin)
              echo "Docker Compose v2 installed via plugin"
              EOF

  tags = {
    Name        = "${terraform.workspace}-sonarqube-elk-server"
    Environment = terraform.workspace
    Purpose     = "SonarQube + ELK Stack"
  }
}

# Output the public IP
output "tools_server_public_ip" {
  value = aws_instance.tools_server.public_ip
}