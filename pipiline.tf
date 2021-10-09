resource "aws_codedeploy_app" "testdeploy-tf" {
  compute_platform = "Server"
  name             = "testdeploy-tf"
}
resource "aws_codedeploy_deployment_group" "tf-dep-grp-2" {
    app_name               = aws_codedeploy_app.testdeploy-tf.name
    deployment_config_name = "CodeDeployDefault.AllAtOnce"
    deployment_group_name  = "tf-dep-grp-2"
    service_role_arn       = "arn:aws:iam::038540414823:role/tf-codedeploy-role"
   
    blue_green_deployment_config {
        deployment_ready_option {
            action_on_timeout    = "CONTINUE_DEPLOYMENT"
            wait_time_in_minutes = 0
        }

        green_fleet_provisioning_option {
            action = "COPY_AUTO_SCALING_GROUP"
        }

        terminate_blue_instances_on_deployment_success {
            action                           = "TERMINATE"
            termination_wait_time_in_minutes = 0
        }
    }

    deployment_style {
        deployment_option = "WITH_TRAFFIC_CONTROL"
        deployment_type   = "BLUE_GREEN"
    }      

    load_balancer_info {

        target_group_info {
            name = "test-WP"
        }
    }

autoscaling_groups = ["${var.autoscaling_groups}"]

}

resource "aws_codepipeline" "cicd_pipeline" {

    name = "tf-cicd"
    role_arn = aws_iam_role.tf-pipeline-role-mohsin.arn

    artifact_store {
        type="S3"
        location = aws_s3_bucket.codepipeline_artifacts.id
    }

    stage {
        name = "Source"
        action{
            name = "Source"
            category = "Source"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = ["tf-code"]
            configuration = {
                FullRepositoryId = "mohsin-integratech/al-huzaifa"
                BranchName   = "main"
                ConnectionArn = var.codestar_connector_credentials
                OutputArtifactFormat = "CODE_ZIP"
            }
        }
    }

    stage {
        name ="Deploy"
        action{
            name = "Deploy"
            category = "Deploy"
            provider = "CodeDeploy"
            version = "1"
            owner = "AWS"
            input_artifacts = ["tf-code"]
            configuration = {
                ApplicationName = "testdeploy-tf"
                DeploymentGroupName = "tf-dep-grp-2"
            }
        }
    }

}


