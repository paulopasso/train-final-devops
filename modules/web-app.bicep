@description('The name of the web app')
param name string

@description('The location of the web app')
param location string

@description('The kind of web app')
param kind string

@description('The ID of the App Service Plan')
param serverFarmResourceId string

@description('The site configuration for the web app')
param siteConfig object

@description('The app settings for the web app')
param appSettingsKeyValuePairs object

@description('The identity configuration for the web app')
param identity object

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  kind: kind
  identity: identity  // Add this line
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: siteConfig
  }
}

resource webAppSettings 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: webApp
  name: 'appsettings'
  properties: appSettingsKeyValuePairs
}

// Add these outputs
output name string = webApp.name
output defaultHostName string = webApp.properties.defaultHostName
output principalId string = webApp.identity.principalId  // Add this line for RBAC
