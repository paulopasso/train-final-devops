@description('The name of the App Service Plan')
param name string

@description('The location of the App Service Plan')
param location string

@description('The SKU of the App Service Plan')
param sku object

@description('The kind of the App Service Plan')
param kind string

@description('Whether to reserve the App Service Plan')
param reserved bool

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: name
  location: location
  sku: sku
  kind: kind
  properties: {
    reserved: reserved
  }
}

// Output needed by the web app
output id string = appServicePlan.id
