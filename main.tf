  GNU nano 4.8                                                                                                                                                                     main.tf                                                                                                                                                                               
terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "5.40.0"
    }
  }
}

variable "pat_token" {
  type        = string
  description = "Specifies the GitHub PAT token or `GITHUB_TOKEN`"
}


provider "github" {
 #token = var.pat_token 
}

data "github_repository" "github-terraform-task-Keksteroid" {
  full_name = "Practical-DevOps-GitHub/github-terraform-task-Keksteroid"
}

resource "github_repository_collaborator" "a_repo_collaborator" {
  repository = data.github_repository.github-terraform-task-Keksteroid.full_name
  username   = "softservedata"
  permission = "write"
}

resource "github_branch_protection" "develop" {
  repository_id       = data.github_repository.github-terraform-task-Keksteroid.id

  pattern          = "develop"
  enforce_admins   = true
  allows_deletions = true

  required_status_checks {
    strict   = false
    contexts = ["ci/travis"]
  }

  required_pull_request_reviews {

    dismiss_stale_reviews          = true
    required_approving_review_count = 2
  }
}

resource "github_branch" "develop" {
  repository = data.github_repository.github-terraform-task-Keksteroid.id
  branch     = "develop"
}

resource "github_repository_file" "codeowners" {
  repository  = "Practical-DevOps-GitHub/github-terraform-task-Keksteroid"
  file   = ".github/CODEOWNERS"
  content     = var.codeowners_content
  commit_message = "Add CODEOWNERS file"
  commit_author       = "Roman Zh."
  commit_email        = "roman.zh@gmail.com"
  overwrite_on_create = true

}

resource "github_branch_protection" "main" {
  repository_id       = data.github_repository.github-terraform-task-Keksteroid.id
  pattern             = "main"
  enforce_admins      = true

  required_pull_request_reviews {
    dismiss_stale_reviews          = false
    require_code_owner_reviews     = true
    required_approving_review_count = 0
 }
}

resource "github_repository_file" "pull_request_template" {
  repository = "github-terraform-task-Keksteroid"
  file = ".github/pull_request_template.md"
  content = local.pull_request_template_content
  commit_message = "Add pull request template"
}

resource "github_repository_deploy_key" "DEPLOY_KEY" {
  repository    = data.github_repository.github-terraform-task-Keksteroid.id
  title         = "DEPLOY_KEY"
  key           = file("${path.module}/deploy_key.pub")
  read_only     = false
}


variable "codeowners_content" {
  description = "Content for the CODEOWNERS file"
  type        = string
}

locals {
  pull_request_template_content = file("${path.module}/pull_request_template.md")
}
