@export()
var prefix = 'petstore'

@export()
func generateResourceName(name string) string => '${prefix}${name}${uniqueString(resourceGroup().id)}'
