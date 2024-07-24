# resource "aws_iam_role" "cloud9_role" {
#   name = "itm-dev-cloud9-ssm-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ssm_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   role       = aws_iam_role.cloud9_role.name
# }

# resource "aws_iam_role_policy_attachment" "cloud9_ssm_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AWSCloud9SSMInstanceProfile"
#   role       = aws_iam_role.cloud9_role.name
# }

# resource "aws_iam_instance_profile" "cloud9_instance_profile" {
#   name = "cloud9-instance-profile"
#   role = aws_iam_role.cloud9_role.name
# }

# resource "aws_cloud9_environment_ec2" "example" {
#   instance_type = "t3.micro"
#   name          = "my-cloud9-env"
#   subnet_id     = aws_subnet.itm_dev_vpc_pub_2a.id
#   connection_type = "CONNECT_SSM"
#   image_id      = "amazonlinux-2023-x86_64"
#   owner_arn     = aws_iam_role.cloud9_role.arn
# }

# output "cloud9_url" {
#   value = "https://ap-northeast-2.console.aws.amazon.com/cloud9/ide/${aws_cloud9_environment_ec2.example.id}"
# }