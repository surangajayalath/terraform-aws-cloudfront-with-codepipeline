################################################################################
# IAM Role for CodeBuild
################################################################################

# IAM Role for CodeBuild with necessary permissions
resource "aws_iam_role" "codebuild_role" {
  name = "${var.pipeline_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role = aws_iam_role.codebuild_role.name
  name = "${var.pipeline_name}-codebuild-role-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:GetLogEvents"]
        Resource = [
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:/codebuild/buildlogs",
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:/codebuild/buildlogs:*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject"]
        Resource = "arn:aws:s3:::${var.pipeline_bucket_name}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation"]
        Resource = "arn:aws:cloudfront::${var.account_id}:distribution/*"
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:*"
      }
    ]
  })
}


################################################################################
# IAM Role for CodePipeline
################################################################################

# IAM Role for CodePipeline with required permissions
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

# IAM Policy for CodePipeline to access S3, CodeBuild, and CodeStar connections
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.pipeline_name}-codepipeline-policy"
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
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": ["codestar-connections:UseConnection"],
      "Resource": "${var.source_connection_arn}"
    },
    {
      "Effect": "Allow",
      "Action": ["codebuild:BatchGetBuilds", "codebuild:StartBuild"],
      "Resource": "*"
    }
  ]
}
EOF
}

################################################################################
# CodePipeline
################################################################################

# Define CodePipeline with Source and Build Stages
resource "aws_codepipeline" "codepipeline" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = data.aws_kms_alias.s3kmskey.arn
      type = "KMS"
    }
  }

  # Source stage fetching code from GitHub
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = var.source_connection_arn
        FullRepositoryId = var.github_repo
        BranchName       = var.branch_name
        DetectChanges    = var.detect_branch_changes
      }
    }
  }

  # Build stage running CodeBuild
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.name
      }
    }
  }
}

################################################################################
# CodeBuild Project
################################################################################

# Define CodeBuild Project for the pipeline
resource "aws_codebuild_project" "codebuild_project" {
  name          = "${var.pipeline_name}-codebuild-project"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = var.image_type
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = var.privileged_mode
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/buildlogs"
      stream_name = "${var.pipeline_name}-codebuild-project"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_file_name
  }
}

################################################################################
# S3 Bucket for CodePipeline Artifacts
################################################################################

# Define S3 Bucket to store pipeline artifacts
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.pipeline_bucket_name
}
