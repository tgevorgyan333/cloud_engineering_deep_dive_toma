terraform {
  backend "s3" {
    bucket         = "myawsbucket-toma"
    dynamodb_table = "terraform_state_lock"
    encrypt        = true
    key            = "projects/myawsbucket-toma.tfstate"
    region         = "us-east-1"
  }
}