terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.2.0"
    }
  }

  required_version = ">= 1.5.0"
}