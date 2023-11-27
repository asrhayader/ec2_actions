#resource "aws_iam_role" "ec2-instance" {
#  name               = "${local.prefix}ec2-${local.repo}"
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Principal": {
#        "Service": "ec2.amazonaws.com"
#      },
#      "Action": "sts:AssumeRole"
#    }
#  ]
#}
#EOF
#}

#resource "aws_iam_role_policy_attachment" "ec2-instance1" {
#  role       = aws_iam_role.ec2-instance.name
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
#}

#resource "aws_iam_role_policy_attachment" "ec2-instance2" {
#  role       = aws_iam_role.ec2-instance.name
#  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
#}
#resource "aws_iam_role_policy_attachment" "ec2-instance3" {
#  role       = aws_iam_role.ec2-instance.name
#  policy_arn = aws_iam_policy.ec2-instance.arn
#}

#resource "aws_iam_instance_profile" "ec2-instance" {
#  name = "ec2-instance"
#  role = aws_iam_role.ec2-instance.name
#}
