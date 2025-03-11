resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_role_${var.project_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role = aws_iam_role.codebuild_role.name
  name = "codebuild_role_policy_${var.project_name}"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Resource" : [
            "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/codebuild/${var.project_name}",
            "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/codebuild/${var.project_name}:*"
          ],
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
        },
        {
          "Effect" : "Allow",
          "Resource" : [
            "arn:aws:s3:::${var.pipeline_bucket_name}-*",
            "arn:aws:s3:::${var.pipeline_bucket_name}/*" 
          ],
          "Action" : [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases",
            "codebuild:BatchPutCodeCoverages"
          ],
          "Resource" : [
            "arn:aws:codebuild:${var.region}:${var.account_id}:report-group/${var.project_name}-*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameters"
          ],
          "Resource" : "arn:aws:ssm:${var.region}:${var.account_id}:*"
        },
        {
          "Effect" : "Allow",
          "Resource" : [
            "arn:aws:logs:${var.region}:${var.account_id}:log-group:/codebuild/buildlogs",
            "arn:aws:logs:${var.region}:${var.account_id}:log-group:/codebuild/buildlogs:*"
          ],
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
        },
        {
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateInvalidation"
      ],
      "Resource": "*"
    }
      ]
    }
  )
}
resource "aws_codepipeline" "codepipeline" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = data.aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = data.aws_kms_alias.s3kmskey.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = var.source_version
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.source_connection_arn
        FullRepositoryId = var.github_repo
        BranchName       = var.branch_name
        DetectChanges    = var.detect_branch_changes
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = var.build_version

      configuration = {
        ProjectName = var.project_name
      }
    }
  }

}

data "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.pipeline_bucket_name}"
}

# resource "aws_s3_bucket" "codepipeline_bucket" {
#   bucket = "${var.pipeline_bucket_name}"
# }

#  resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
#    bucket = aws_s3_bucket.codepipeline_bucket.id
#    depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
#    acl    = "private"
#  }

#  resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
#    bucket = aws_s3_bucket.codepipeline_bucket.id
#    rule {
#      object_ownership = "ObjectWriter"
#    }
#  }

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.pipeline_name}-pipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.pipeline_name}-codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${data.aws_s3_bucket.codepipeline_bucket.arn}",
        "${data.aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:UseConnection"
      ],
      "Resource": "${var.source_connection_arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_codebuild_project" "codebuild_project" {
  name           = var.project_name
  build_timeout  = var.build_timeout
  description    = var.description
  service_role   = aws_iam_role.codebuild_role.arn
  encryption_key = data.aws_kms_alias.s3kmskey.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = var.image_type
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = var.privileged_mode

    environment_variable {
      name  = "NPM_PKG_TOKEN"
      value = var.npm_pkg_token_path
      type  = "PARAMETER_STORE"
    }
    environment_variable {
      name  = "GIT_USER_NAME"
      value = var.git_user_name
      type  = "PARAMETER_STORE"
    }
    environment_variable {
      name  = "GIT_USER_TOKEN"
      value = var.git_user_token
      type  = "PARAMETER_STORE"
    }

  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/buildlogs"
      stream_name = var.project_name
    }
  }


  source {
    type = "CODEPIPELINE"
    buildspec = var.buildspec_file_name
  } 
}

