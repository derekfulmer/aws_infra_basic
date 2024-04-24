resource "aws_iam_instance_profile" "iam_profile_host_profile" {
  name = "${var.stack_name}"
  role = aws_iam_role.iam_role.name
}

resource "aws_iam_role_policy_attachment" "attach_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ztgate_role.name
}

resource "aws_iam_role" "iam_role" {
  name = "${var.stack_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
