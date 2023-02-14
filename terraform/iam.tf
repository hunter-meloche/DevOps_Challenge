# IAM role for EC2 instances to pull ECR images
resource "aws_iam_role" "ecr_puller_role" {
  name = "ecr_puller_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
      },
    ],
  })
}

# IAM policy to allow EC2s to pull ECR images
resource "aws_iam_policy" "ecr_puller_policy" {
  name = "ecr_puller_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "ecr:GetAuthorizationToken",
        Effect = "Allow",
        Resource = "*",
      },
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Effect = "Allow",
        Resource = "*",
      },
    ],
  })
}

# Attaches policy to role that enable EC2s to pull ECR images
resource "aws_iam_role_policy_attachment" "ecr_puller_attachment" {
  policy_arn = aws_iam_policy.ecr_puller_policy.arn
  role       = aws_iam_role.ecr_puller_role.name
}

# Instance profile with ecr_puller role
resource "aws_iam_instance_profile" "ecr_puller" {
  name = "ecr_puller_profile"
  role = aws_iam_role.ecr_puller_role.name
}
