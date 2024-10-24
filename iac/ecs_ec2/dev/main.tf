module "vpc" {
  source = "../modules/vpc"
}

/*
module "firewall" {
  source = "../modules/firewall"
  vpc_details = vpc.vpc_details
}
*/
