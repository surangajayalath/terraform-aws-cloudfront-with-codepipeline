output "aws_codebuild_project_arn" {
   description = "Arn of the project"
   value       = aws_codebuild_project.codebuild_project.arn
 }

 output "aws_codebuild_project_name" {
   description = "name of the project"
   value       = aws_codebuild_project.codebuild_project.name
 }
