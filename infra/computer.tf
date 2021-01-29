data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instances_sg.id] 
  subnet_id = aws_subnet.pub_subnet.id
  count = 1
  key_name = aws_key_pair.deployer.key_name
}

resource "aws_security_group" "instances_sg" {
    vpc_id      = aws_vpc.vpc.id

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "rds_sg" {
    vpc_id      = aws_vpc.vpc.id

    ingress {
        protocol        = "tcp"
        from_port       = 5432
        to_port         = 5432
        cidr_blocks     = ["0.0.0.0/0"]
        security_groups = [aws_security_group.instances_sg.id]
    }

    egress {
        from_port       = 0
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_db_subnet_group" "db_subnet_group" {
    subnet_ids  = [aws_subnet.priv_subnet1.id, aws_subnet.priv_subnet2.id]
}

resource "aws_db_instance" "postgres" {
    identifier                = "postgres"
    allocated_storage         = 5
    backup_retention_period   = 2
    backup_window             = "01:00-01:30"
    maintenance_window        = "sun:03:00-sun:03:30"
    multi_az                  = true
    engine                    = "postgres"
    engine_version            = "9.6.9"
    storage_encrypted         = false
    instance_class            = "db.t2.micro"
    name                      = "wordcount"
    username                  = "worker"
    password                  = "rootworker"
    port                      = "5432"
    db_subnet_group_name      = aws_db_subnet_group.db_subnet_group.id
    vpc_security_group_ids    = [aws_security_group.rds_sg.id, aws_security_group.instances_sg.id]
    skip_final_snapshot       = true
    final_snapshot_identifier = "wordcount-final"
    publicly_accessible       = true
}


output "servers_web_ips" {
  value = aws_instance.web.*.public_ip
}

output "servers_db_ips" {
  value = aws_db_instance.postgres.*.endpoint
}


