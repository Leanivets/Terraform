provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_security_group" "docker-sg" {
  name        = "docker-sg"
  description = "Allow traffic for docker hosts"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "docker" {
  ami = "ami-0370f4064dbc392b9"
  instance_type = "t2.micro"
  key_name = "Ubuntu"

  security_groups = [
    "${aws_security_group.docker-sg.name}",
  ]

  connection {
    type     = "ssh"
    user     = "${var.ssh-user}"
    private_key = "${file("${var.ssh_key}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install docker-ce -y",
    ]
  }

  tags {
    Name = "Docker"
  }
}
