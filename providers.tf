terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.23.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "azurerm" {
  features {
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
  }
  subscription_id = 
  client_id       = 
  client_secret   = 
  tenant_id       = 
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}