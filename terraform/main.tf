provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "cv_challenge_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.instance_name
  }
}

resource "aws_subnet" "cv_challenge_subnet" {
  vpc_id            = aws_vpc.cv_challenge_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = var.instance_name
  }
}

resource "aws_internet_gateway" "cv_challenge_igw" {
  vpc_id = aws_vpc.cv_challenge_vpc.id
  tags = {
    Name = var.instance_name
  }
}

resource "aws_route_table" "cv_challenge_route_table" {
  vpc_id = aws_vpc.cv_challenge_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cv_challenge_igw.id
  }
}

resource "aws_route_table_association" "cv_challenge_route_table_association" {
  subnet_id      = aws_subnet.cv_challenge_subnet.id
  route_table_id = aws_route_table.cv_challenge_route_table.id
}

resource "aws_security_group" "cv_challenge_security_group" {
  name        = var.instance_name
  description = "Security group for the CV Challenge"
  vpc_id      = aws_vpc.cv_challenge_vpc.id
  tags = {
    Name = "cv-challenge-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "cv_challenge_sg_allow_ssh" {
  security_group_id = aws_security_group.cv_challenge_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "cv_challenge_sg_allow_http" {
  security_group_id = aws_security_group.cv_challenge_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "cv_challenge_sg_allow_https" {
  security_group_id = aws_security_group.cv_challenge_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "cv_challenge_sg_allow_backend" {
  security_group_id = aws_security_group.cv_challenge_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8000
  ip_protocol       = "tcp"
  to_port           = 8000
}

resource "aws_vpc_security_group_ingress_rule" "cv_challenge_sg_allow_adminer" {
  security_group_id = aws_security_group.cv_challenge_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "cv_challenge_sg_allow_prometheus" {
  security_group_id = aws_security_group.cv_challenge_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 9090
  ip_protocol       = "tcp"
  to_port           = 9090
}

resource "aws_vpc_security_group_ingress_rule" "cv_challenge_sg_allow_grafana" {
  security_group_id = aws_security_group.cv_challenge_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

resource "aws_vpc_security_group_egress_rule" "cv_challenge_sg_allow_all" {
  security_group_id = aws_security_group.cv_challenge_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "cv_challenge" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.cv_challenge_subnet.id
  vpc_security_group_ids      = [aws_security_group.cv_challenge_security_group.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 16
    volume_type = "gp2"
  }

  tags = {
    Name = var.instance_name
  }

  # Wait for the instance to be fully available before proceeding
  provisioner "remote-exec" {
    inline = ["echo 'Server is ready!'"]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.ini.tpl", {
    app_ip_address = aws_instance.cv_challenge.public_ip
    ssh_user       = var.ssh_user
    private_key_path   = var.private_key_path
  })
  filename = "../ansible/inventory.ini"

  depends_on = [aws_instance.cv_challenge]
}

resource "null_resource" "ansible_playbook" {
  depends_on = [
    aws_instance.cv_challenge,
    local_file.ansible_inventory
  ]

  triggers = {
    app_serip_addressver_ips = aws_instance.cv_challenge.public_ip
    inventory_content_hash   = local_file.ansible_inventory.content_base64sha256
    main_compose_file_hash = filesha256("../docker-compose.yml") 
  }

  provisioner "local-exec" {
    command = <<EOT
        echo "Waiting for SSH on instance ${aws_instance.cv_challenge.public_ip}..."
        timeout 300 bash -c 'until ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.private_key_path} ${var.ssh_user}@${aws_instance.cv_challenge.public_ip} "echo Hello from host"; do sleep 10; done'

        echo "Running Ansible playbook..."
        if [ ! -f ../ansible/inventory.ini ]; then
            echo "ERROR: Ansible inventory file ../ansible/inventory.ini NOT FOUND!"
            exit 1
        fi
        ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/inventory.ini ../ansible/playbook.yml --extra-vars "target_host_ip=${aws_instance.cv_challenge.public_ip} domain_name=${var.domain_name}"
    EOT
  }
}