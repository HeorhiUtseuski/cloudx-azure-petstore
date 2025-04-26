data "azurerm_key_vault_secret" "applicationInsightsConnectionString" {
  name         = var.application_insights_connection_string_name
  key_vault_id = var.key_vault_id
}

locals {
  base_env_variables = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = data.azurerm_key_vault_secret.applicationInsightsConnectionString.value,
    "APPLICATIONINSIGHTS_ROLE_NAME"              = lower(var.application_name),
    "${upper(var.application_name)}_SERVER_PORT" = "8080"
  }

  env_variables = merge(local.base_env_variables, var.enviroment_variables)
}


resource "azurerm_container_app" "containerApp" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  revision_mode                = var.revision_mode

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_id]
  }

  registry {
    server = var.container_registry_login_server
    identity = var.user_assigned_id
  }

  ingress {
    external_enabled           = true
    transport                  = "auto"
    allow_insecure_connections = true
    target_port                = 8080

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    container {
      name   = var.name
      image  = "${var.container_registry_login_server}/${var.application_name}:${var.application_tag}"
      cpu    = "0.25"
      memory = "0.5Gi"

      dynamic "env" {
        for_each = local.env_variables
        content {
          name  = env.key
          value = env.value
        }
      }
    }

    min_replicas = 1
    max_replicas = 3

    http_scale_rule {
      name                = "pet-http-rule"
      concurrent_requests = "50"
    }
  }
}