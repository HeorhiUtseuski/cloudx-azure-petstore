targetScope='subscription'

module petStoreArg 'modules/resourceGroup.bicep' = {
  scope: subscription()
  params: {
    name: 'petStoreArgModule6'
  }
}
