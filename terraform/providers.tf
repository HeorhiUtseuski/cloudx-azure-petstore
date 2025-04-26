terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.26.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.2.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }

    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}
