@export()
var resource = {
  functionAppName: maskedName('-afa-')
  applicationServicePlanName: maskedName('-aasp-')
  logAnalyticsWorkspaceName: maskedName('-alaw-')
  applicationInsightsName: maskedName('-aai-')
  storageAccountsName: maskedName('asa')
  containerRegistryName: maskedName('acr')
  containerAppEnvironmentName: maskedName('-acae-')
  containerAppPetStoreProductServiceName: maskedName('-acaprs-')
  containerAppPetStorePetServiceName: maskedName('-acapes-')
  containerAppPetStoreOrderServiceName: maskedName('-acaos-')
  containerAppPetStoreAppName: maskedName('-acaa-')
}

var prefix = 'petstore'
var sufix = uniqueString(resourceGroup().id)

@export()
func maskedName(name string) string => '${prefix}${name}${sufix}'
