@export()
var prefix = 'petstore'

@export()
func generateResourceName(name string) string => '${prefix}${name}${uniqueString(resourceGroup().id)}'

@export()
var location = resourceGroup().location

@export()
var revisionMode = 'Single'