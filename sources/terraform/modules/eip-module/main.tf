resource "aws_eip" "my_eip" {
    domain = "vpc"

    provisioner "local-exec" {
        command = "echo IP: ${aws_eip.my_eip.public_ip} > files/ec2_IP.txt"
    }
}

