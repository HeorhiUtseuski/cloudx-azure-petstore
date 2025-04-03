variable "azureResourceName" {
  default = {
    resourceGroup           = "petstorearg"
    containerRegistry       = "petstoreacr2609"
    userAssignedIdentity    = "petstoreauai"
    logAnalyticsWorkspace   = "petstorealaw"
    applicationInsights     = "petstoreaai"
    containerAppEnvironment = "petstoreacae"
    containerApp            = "aca"
    containerAppSecretName  = "pswd-2609"
    scaleRule               = "petstoresrh"
  }
  type = map(string)
}

variable "azureLocation" {
  default = {
    westeurope = "westeurope"
  }
  type = map(string)
}

variable "azureSku" {
  default = {
    standard  = "Standard"
    b1        = "B1"
    basic     = "Basic"
    rerGB2018 = "PerGB2018"
  }
  type = map(string)
}

variable "azureApplicationName" {
  default = {
    webApp          = "petstoreapp"
    order_service   = "petstoreorderservice"
    pet_service     = "petstorepetservice"
    product_service = "petstoreproductservice"
  }
  type = map(string)
}

variable "azureApplicationVersion" {
  default = {
    current = "1.0.3"
    latest  = "latest"
  }
  type = map(string)
}

variable "azureContainerConfig" {
  default = {
    revisionMode = "Single"
    identityType = "UserAssigned"
  }
  type = map(string)
}