resource "aws_instance" "lab_05" {
  # This is an Ubuntu 24.04 instance. 
  ami           = "ami-0f5fcdfbd140e4ab7"
  instance_type = "t2.micro"
  key_name      = "aws_key"
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_tls.id,
    aws_security_group.allow_http.id,
    aws_security_group.egress.id,
  ]

  tags = {
    Name                    = "Lab-05"
    Vanquisher_of_Gothmog   = "Ecthelion"
    Vanquisher_of_Ecthelion = "Gothmog"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = "ssh-ed25519 AAAA...."
}

# Security Groups

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_security_group" "egress" {
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
