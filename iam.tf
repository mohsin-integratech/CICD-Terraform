resource "aws_iam_role" "tf-pipeline-role-mohsin" {
  name = "tf-pipeline-role-mohsin"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "tf-cicd-pipeline-policies" {
    statement{
        sid = ""
        actions = ["codestar-connections:UseConnection"]
        resources = ["arn:aws:codestar-connections:*"]
        effect = "Allow"
    }
    statement{
        sid = ""
        actions = ["cloudwatch:*", "s3:*", "codedeploy:*"]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "tf-cicd-pipeline-policy" {
    name = "tf-cicd-pipeline-policy"
    path = "/"
    description = "Pipeline policy"
    policy = data.aws_iam_policy_document.tf-cicd-pipeline-policies.json
}

resource "aws_iam_role_policy_attachment" "tf-cicd-pipeline-attachment" {
    policy_arn = aws_iam_policy.tf-cicd-pipeline-policy.arn
    role = aws_iam_role.tf-pipeline-role-mohsin.id
}


resource "aws_iam_role" "tf-codedeploy-role" {
  name = "tf-codedeploy-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "tf-cicd-deploy-policies" {
    statement{
        sid = ""
        actions = ["logs:*", "s3:*", "codedeploy:*","iam:PassRole", "EC2:RunInstances", "EC2:CreateTags"]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "tf-cicd-deploy-policy" {
    name = "tf-cicd-deploy-policy"
    path = "/"
    description = "Codedeploy policy"
    policy = data.aws_iam_policy_document.tf-cicd-deploy-policies.json
}

resource "aws_iam_role_policy_attachment" "tf-cicd-codedeploy-attachment1" {
    policy_arn  = aws_iam_policy.tf-cicd-deploy-policy.arn
    role        = aws_iam_role.tf-codedeploy-role.id
}

resource "aws_iam_role_policy_attachment" "tf-cicd-codedeploy-attachment2" {
    policy_arn  = "arn:aws:iam::aws:policy/PowerUserAccess"
    role        = aws_iam_role.tf-codedeploy-role.id
}
resource "aws_iam_role_policy_attachment" "tf-cicd-codedeploy-attachment3" {
    policy_arn  = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
    role        = aws_iam_role.tf-codedeploy-role.id
}
resource "aws_iam_role_policy_attachment" "tf-cicd-codedeploy-attachment4" {
    policy_arn  = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
    role        = aws_iam_role.tf-codedeploy-role.id
}