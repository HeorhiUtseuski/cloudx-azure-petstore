resource "azurerm_resource_group" "petStoreArg" {
  name     = var.azureResourceName.resourceGroup
  location = var.azureLocation.westeurope
}

resource "azurerm_log_analytics_workspace" "petStoreAlaw" {
  name                = var.azureResourceName.logAnalyticsWorkspace
  resource_group_name = azurerm_resource_group.petStoreArg.name
  location            = azurerm_resource_group.petStoreArg.location
  sku                 = var.azureSku.rerGB2018
  retention_in_days   = 30
}

resource "azurerm_application_insights" "petStoreAai" {
  name                = var.azureResourceName.applicationInsights
  resource_group_name = azurerm_resource_group.petStoreArg.name
  location            = azurerm_resource_group.petStoreArg.location
  workspace_id        = azurerm_log_analytics_workspace.petStoreAlaw.id
  application_type    = "java"

  depends_on = [azurerm_log_analytics_workspace.petStoreAlaw]
}

resource "azurerm_container_registry" "petStoreAcr" {
  name                = var.azureResourceName.containerRegistry
  resource_group_name = azurerm_resource_group.petStoreArg.name
  location            = azurerm_resource_group.petStoreArg.location
  sku                 = var.azureSku.standard
  admin_enabled       = true
}

resource "docker_image" "webApp" {
  name = var.azureApplicationName.webApp
  build {
    context = "./${var.azureApplicationName.webApp}"
    tag = [
      "${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.webApp}:${var.azureApplicationVersion.latest}",
      "${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.webApp}:${var.azureApplicationVersion.current}"
    ]
  }

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.cwd, "./${var.azureApplicationName.webApp}*/**") : filesha1(f)]))
  }
}

resource "docker_image" "order_service" {
  name = var.azureApplicationName.order_service
  build {
    context = "./${var.azureApplicationName.order_service}"
    tag = [
      "${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.order_service}:${var.azureApplicationVersion.latest}",
      "${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.order_service}:${var.azureApplicationVersion.current}"
    ]
  }

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.cwd, "./${var.azureApplicationName.order_service}*/**") : filesha1(f)]))
  }
}

resource "docker_image" "pet_service" {
  name = var.azureApplicationName.pet_service
  build {
    context = "./${var.azureApplicationName.pet_service}"
    tag = [
      "${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.pet_service}:${var.azureApplicationVersion.latest}",
      "${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.pet_service}:${var.azureApplicationVersion.current}"
    ]
  }

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.cwd, "./${var.azureApplicationName.pet_service}*/**") : filesha1(f)]))
  }
}

resource "docker_image" "product_service" {
  name = var.azureApplicationName.product_service
  build {
    context = "./${var.azureApplicationName.product_service}"
    tag = [
      "${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.product_service}:${var.azureApplicationVersion.latest}",
      "${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.product_service}:${var.azureApplicationVersion.current}"
    ]
  }

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.cwd, "./${var.azureApplicationName.product_service}*/**") : filesha1(f)]))
  }
}

resource "null_resource" "step_acr_login" {
  provisioner "local-exec" {
    command     = "az acr login --name ${azurerm_container_registry.petStoreAcr.name}"
    interpreter = ["PowerShell", "-Command"]
  }

  triggers = {
    combined_image_digests = join(",", [
      docker_image.webApp.repo_digest,
      docker_image.order_service.repo_digest,
      docker_image.pet_service.repo_digest,
      docker_image.product_service.repo_digest
    ])
  }

  depends_on = [docker_image.webApp,
    docker_image.order_service,
    docker_image.pet_service,
    docker_image.product_service,
    azurerm_container_registry.petStoreAcr
  ]
}

resource "null_resource" "stepBuildAndPush_webApp" {
  triggers = {
    image_digest = docker_image.webApp.repo_digest
  }

  provisioner "local-exec" {
    command     = <<EOT
      docker push ${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.webApp}:${var.azureApplicationVersion.latest};
      docker push ${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.webApp}:${var.azureApplicationVersion.current};
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [
    null_resource.step_acr_login,
    docker_image.webApp
  ]
}

resource "null_resource" "stepBuildAndPush_order_service" {
  triggers = {
    image_digest = docker_image.order_service.repo_digest
  }

  provisioner "local-exec" {
    command     = <<EOT
      docker push ${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.order_service}:${var.azureApplicationVersion.latest};
      docker push ${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.order_service}:${var.azureApplicationVersion.current};
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [
    null_resource.step_acr_login,
    docker_image.order_service
  ]
}

resource "null_resource" "stepBuildAndPush_pet_service" {
  triggers = {
    image_digest = docker_image.pet_service.repo_digest
  }

  provisioner "local-exec" {
    command     = <<EOT
      docker push ${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.pet_service}:${var.azureApplicationVersion.latest};
      docker push ${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.pet_service}:${var.azureApplicationVersion.current};
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [
    null_resource.step_acr_login,
    docker_image.pet_service
  ]
}

resource "null_resource" "stepBuildAndPush_product_service" {
  triggers = {
    image_digest = docker_image.product_service.repo_digest
  }

  provisioner "local-exec" {
    command     = <<EOT
      docker push ${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.product_service}:${var.azureApplicationVersion.latest};
      docker push ${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.product_service}:${var.azureApplicationVersion.current};
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [
    null_resource.step_acr_login,
    docker_image.product_service
  ]
}

resource "azurerm_container_app_environment" "petStoreAcae" {
  name                       = var.azureResourceName.containerAppEnvironment
  resource_group_name        = azurerm_resource_group.petStoreArg.name
  location                   = azurerm_resource_group.petStoreArg.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.petStoreAlaw.id

  depends_on = [azurerm_log_analytics_workspace.petStoreAlaw]
}

resource "azurerm_container_app" "petStoreAca_webApp" {
  container_app_environment_id = azurerm_container_app_environment.petStoreAcae.id
  name                         = "${var.azureApplicationName.webApp}-${var.azureResourceName.containerApp}"
  resource_group_name          = azurerm_resource_group.petStoreArg.name
  revision_mode                = var.azureContainerConfig.revisionMode

  secret {
    name  = "${var.azureApplicationName.webApp}-${var.azureResourceName.containerAppSecretName}"
    value = azurerm_container_registry.petStoreAcr.admin_password
  }

  registry {
    server               = azurerm_container_registry.petStoreAcr.login_server
    username             = azurerm_container_registry.petStoreAcr.admin_username
    password_secret_name = "${var.azureApplicationName.webApp}-${var.azureResourceName.containerAppSecretName}"
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    transport                  = "auto"
    target_port                = 8080
    traffic_weight {
      percentage      = 100
      revision_suffix = "v1"
    }
  }

  template {
    revision_suffix = "v1"
    container {
      name  = "${var.azureApplicationName.webApp}-${var.azureResourceName.containerApp}-cn"
      image = "${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.webApp}:${var.azureApplicationVersion.current}"
      # image  = docker_image.webApp.name
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "PETSTOREAPP_SERVER_PORT"
        value = "8080"
      }

      env {
        name  = "PETSTOREORDERSERVICE_URL"
        value = "https://${azurerm_container_app.petStoreAca_order_service.ingress[0].fqdn}"
      }

      env {
        name  = "PETSTOREPETSERVICE_URL"
        value = "https://${azurerm_container_app.petStoreAca_pet_service.ingress[0].fqdn}"
      }

      env {
        name  = "PETSTOREPRODUCTSERVICE_URL"
        value = "https://${azurerm_container_app.petStoreAca_product_service.ingress[0].fqdn}"
      }

      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = azurerm_application_insights.petStoreAai.connection_string
      }

      env {
        name  = "APPLICATIONINSIGHTS_ROLE_NAME"
        value = var.azureApplicationName.webApp
      }
    }

    http_scale_rule {
      concurrent_requests = 50
      name                = var.azureResourceName.scaleRule
    }

    min_replicas = 1
    max_replicas = 1
  }

  provisioner "local-exec" {
    command     = <<EOT
      az containerapp update --name "${azurerm_container_app.petStoreAca_webApp.name}" --resource-group "${azurerm_resource_group.petStoreArg.name}" --runtime=java --enable-java-metrics=true
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [
    null_resource.stepBuildAndPush_webApp,
    azurerm_container_app.petStoreAca_order_service,
    azurerm_container_app.petStoreAca_pet_service,
    azurerm_container_app.petStoreAca_product_service
  ]
}

resource "azurerm_container_app" "petStoreAca_order_service" {
  container_app_environment_id = azurerm_container_app_environment.petStoreAcae.id
  name                         = "${var.azureApplicationName.order_service}-${var.azureResourceName.containerApp}"
  resource_group_name          = azurerm_resource_group.petStoreArg.name
  revision_mode                = var.azureContainerConfig.revisionMode

  secret {
    name  = "${var.azureApplicationName.order_service}-${var.azureResourceName.containerAppSecretName}"
    value = azurerm_container_registry.petStoreAcr.admin_password
  }

  registry {
    server               = azurerm_container_registry.petStoreAcr.login_server
    username             = azurerm_container_registry.petStoreAcr.admin_username
    password_secret_name = "${var.azureApplicationName.order_service}-${var.azureResourceName.containerAppSecretName}"
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    transport                  = "auto"
    target_port                = 8080
    traffic_weight {
      percentage      = 100
      revision_suffix = "v1"
    }
  }

  template {
    revision_suffix = "v1"
    container {
      name  = "${var.azureApplicationName.order_service}-${var.azureResourceName.containerApp}-cn"
      image = "${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.order_service}:${var.azureApplicationVersion.current}"
      # image  = docker_image.order_service.name
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "PETSTOREORDERSERVICE_SERVER_PORT"
        value = "8080"
      }

      env {
        name  = "PETSTOREPRODUCTSERVICE_URL"
        value = "https://${azurerm_container_app.petStoreAca_product_service.ingress[0].fqdn}"
      }

      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = azurerm_application_insights.petStoreAai.connection_string
      }

      env {
        name  = "APPLICATIONINSIGHTS_ROLE_NAME"
        value = var.azureApplicationName.order_service
      }
    }

    http_scale_rule {
      concurrent_requests = 50
      name                = var.azureResourceName.scaleRule
    }

    min_replicas = 1
    max_replicas = 3
  }

  provisioner "local-exec" {
    command     = <<EOT
      az containerapp update --name "${azurerm_container_app.petStoreAca_order_service.name}" --resource-group "${azurerm_resource_group.petStoreArg.name}" --runtime=java --enable-java-metrics=true
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [
    null_resource.stepBuildAndPush_order_service,
    azurerm_container_app.petStoreAca_product_service
  ]
}

resource "azurerm_container_app" "petStoreAca_pet_service" {
  container_app_environment_id = azurerm_container_app_environment.petStoreAcae.id
  name                         = "${var.azureApplicationName.pet_service}-${var.azureResourceName.containerApp}"
  resource_group_name          = azurerm_resource_group.petStoreArg.name
  revision_mode                = var.azureContainerConfig.revisionMode

  secret {
    name  = "${var.azureApplicationName.pet_service}-${var.azureResourceName.containerAppSecretName}"
    value = azurerm_container_registry.petStoreAcr.admin_password
  }

  registry {
    server               = azurerm_container_registry.petStoreAcr.login_server
    username             = azurerm_container_registry.petStoreAcr.admin_username
    password_secret_name = "${var.azureApplicationName.pet_service}-${var.azureResourceName.containerAppSecretName}"
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    transport                  = "auto"
    target_port                = 8080
    traffic_weight {
      percentage      = 100
      revision_suffix = "v1"
    }
  }

  template {
    revision_suffix = "v1"
    container {
      name  = "${var.azureApplicationName.pet_service}-${var.azureResourceName.containerApp}-cn"
      image = "${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.pet_service}:${var.azureApplicationVersion.current}"
      # image  = docker_image.pet_service.name
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "PETSTOREPETSERVICE_SERVER_PORT"
        value = "8080"
      }

      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = azurerm_application_insights.petStoreAai.connection_string
      }

      env {
        name  = "APPLICATIONINSIGHTS_ROLE_NAME"
        value = var.azureApplicationName.pet_service
      }
    }

    http_scale_rule {
      concurrent_requests = 50
      name                = var.azureResourceName.scaleRule
    }

    min_replicas = 1
    max_replicas = 3
  }

  provisioner "local-exec" {
    command     = <<EOT
      az containerapp update --name "${azurerm_container_app.petStoreAca_pet_service.name}" --resource-group "${azurerm_resource_group.petStoreArg.name}" --runtime=java --enable-java-metrics=true
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [
    null_resource.stepBuildAndPush_pet_service
  ]
}

resource "azurerm_container_app" "petStoreAca_product_service" {
  container_app_environment_id = azurerm_container_app_environment.petStoreAcae.id
  name                         = "${var.azureApplicationName.product_service}-${var.azureResourceName.containerApp}"
  resource_group_name          = azurerm_resource_group.petStoreArg.name
  revision_mode                = var.azureContainerConfig.revisionMode

  secret {
    name  = "${var.azureApplicationName.product_service}-${var.azureResourceName.containerAppSecretName}"
    value = azurerm_container_registry.petStoreAcr.admin_password
  }

  registry {
    server               = azurerm_container_registry.petStoreAcr.login_server
    username             = azurerm_container_registry.petStoreAcr.admin_username
    password_secret_name = "${var.azureApplicationName.product_service}-${var.azureResourceName.containerAppSecretName}"
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    transport                  = "auto"
    target_port                = 8080
    traffic_weight {
      percentage      = 100
      revision_suffix = "v1"
    }
  }

  template {
    revision_suffix = "v1"
    container {
      name  = "${var.azureApplicationName.product_service}-${var.azureResourceName.containerApp}-cn"
      image = "${azurerm_container_registry.petStoreAcr.login_server}/${var.azureApplicationName.product_service}:${var.azureApplicationVersion.current}"
      # image  = docker_image.product_service.name
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "PETSTOREPRODUCTSERVICE_SERVER_PORT"
        value = "8080"
      }

      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = azurerm_application_insights.petStoreAai.connection_string
      }

      env {
        name  = "APPLICATIONINSIGHTS_ROLE_NAME"
        value = var.azureApplicationName.product_service
      }
    }

    http_scale_rule {
      concurrent_requests = 50
      name                = var.azureResourceName.scaleRule
    }

    min_replicas = 1
    max_replicas = 3
  }

  provisioner "local-exec" {
    command     = <<EOT
      az containerapp update --name "${azurerm_container_app.petStoreAca_product_service.name}" --resource-group "${azurerm_resource_group.petStoreArg.name}" --runtime=java --enable-java-metrics=true
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [
    null_resource.stepBuildAndPush_product_service
  ]
}