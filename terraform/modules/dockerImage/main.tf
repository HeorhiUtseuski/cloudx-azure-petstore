data "azurerm_key_vault_secret" "containerRegistryAdminUsernameSecret" {
  name         = var.admin_username_secret_name
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "containerRegistryAdminPasswordSecret" {
  name         = var.admin_password_secret_name
  key_vault_id = var.key_vault_id
}

locals {
  registry_host = trimsuffix("https://${var.container_registry_login_server}", "/")
  image_tag     = "${var.container_registry_login_server}/${var.name}:${var.image_tag}"
}

resource "docker_image" "dockerImage" {
  name     = local.image_tag
  provider = docker

  build {
    context = var.context_path
    auth_config {
      host_name = local.registry_host
      user_name = data.azurerm_key_vault_secret.containerRegistryAdminUsernameSecret.value
      password  = data.azurerm_key_vault_secret.containerRegistryAdminPasswordSecret.value
    }
    tag = [local.image_tag]
  }

  force_remove = true
  keep_locally = false

  triggers = {
    dir_sha1 = sha1(join("", [
      for f in fileset("${path.root}/../${var.name}", "**/*") :
      filesha1("${path.root}/../${var.name}/${f}")
    ]))
  }
}

resource "null_resource" "docker_push" {
  provisioner "local-exec" {
    command = <<EOT
      az acr login --name ${var.container_registry_name}
      docker build -t ${local.image_tag}:${var.image_tag} ${var.context_path}
      docker push ${local.image_tag}
    EOT
  }

  triggers = {
    dir_sha1 = sha1(join("", [
      for f in fileset("${path.root}/../${var.name}", "**/*") :
      filesha1("${path.root}/../${var.name}/${f}")
    ]))
  }

  depends_on = [docker_image.dockerImage]
}