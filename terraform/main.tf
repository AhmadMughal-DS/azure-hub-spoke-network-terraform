locals {
  name_prefix = var.project_name
}

module "hubspoke" {
  source      = "./modules/hubspoke"
  name_prefix = local.name_prefix
  location    = var.location
  environment = var.environment
}
