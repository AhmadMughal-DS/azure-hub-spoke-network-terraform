# Remote state backend (production). Create a resource group, storage account and
# container, then uncomment and run `terraform init -migrate-state`.
#
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "ahmad-tfstate-rg"
#     storage_account_name = "ahmadtfstate"
#     container_name       = "tfstate"
#     key                  = "azure-hub-spoke-network-terraform.tfstate"
#   }
# }
