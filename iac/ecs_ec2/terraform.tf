terraform {
 /*
  cloud {
    organization = "CloudMigrate"
    workspaces {
      name = "learn-terraform-provider-versioning"
    }
  }
 */ 
  

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "<= 5.72.0"
    }
  }

  required_version = "~> 1.2"
}

