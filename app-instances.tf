/* Setup our aws provider */
provider "aws" {
  region = var.region
  # Read the rest from env variables
}

# Create the SWARM manager node
#TODO Allow more than one manager
resource "aws_instance" "swarm_manager" {
  ami = coalesce(var.ami_id, data.aws_ami.ubuntu.id)
  instance_type = var.instance_type
  vpc_security_group_ids = [
    aws_security_group.allow_http_traffic.id,
    aws_security_group.ssh_from_other_ec2_instances.id,
  ]
  associate_public_ip_address = true
  key_name = aws_key_pair.deployer.key_name
  subnet_id = aws_subnet.public_subnets[0].id
  connection {
    host = coalesce(self.public_ip, self.private_ip)
    type = "ssh"
    user = "ubuntu"
    private_key = file("${path.module}/id_rsa")
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -q update",
      "sudo apt-get install -q -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository  \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get -q update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "sudo docker swarm init",
      "sudo docker swarm join-token --quiet worker > /home/ubuntu/token",
    ]
  }

  # Mount the project root inside the manager node
  provisioner "file" {
    source = "proj"
    destination = "/home/ubuntu/"
  }

  tags = {
    Name = "${local.stack_name}-manager-1"
  }
}

resource "aws_instance" "swarm_worker" {
  count = 2
  ami = coalesce(var.ami_id, data.aws_ami.ubuntu.id)
  instance_type = var.instance_type
  vpc_security_group_ids = [
    aws_security_group.allow_http_traffic.id,
    aws_security_group.ssh_from_other_ec2_instances.id
  ]
  key_name = aws_key_pair.deployer.key_name
  subnet_id = aws_subnet.public_subnets[0].id
  associate_public_ip_address = true
  connection {
    host = coalesce(self.public_ip, self.private_ip)
    type = "ssh"
    user = "ubuntu"
    private_key = file("${path.module}/id_rsa")
  }
  provisioner "file" {
    source = "id_rsa"
    destination = "/home/ubuntu/manager_connection_key.pem"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository  \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "sudo chmod 400 /home/ubuntu/manager_connection_key.pem",

      # Copy the Swarm join token from the manager node to the current worker node
      "sudo scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i manager_connection_key.pem ubuntu@${aws_instance.swarm_manager.private_ip}:/home/ubuntu/token .",

      # Join the swarm as a worker
      "sudo docker swarm join --token $(cat /home/ubuntu/token) ${aws_instance.swarm_manager.private_ip}:2377",

      # Remove the SSH key to access the manager node, from the disk of the worker for extra security
      "sudo rm /home/ubuntu/manager_connection_key.pem"
    ]
  }
  tags = {
    Name = "${local.stack_name}-worker-${count.index}"
  }
}

