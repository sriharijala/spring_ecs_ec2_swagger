module "db" {
  source = "./module/db/"  
  project = var.cluster_name
  vpc_id = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
}