resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "pipeline-arrtifacts-mohsin-terraform"
  acl    = "private"
  force_destroy = true
}
