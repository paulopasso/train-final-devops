@description('The API App name (backend)')
param appServiceAPIAppName string

@description('The Azure location where the Backend API App will be deployed')
param location string = resourceGroup().location

@description('The App Service Plan ID for the Backend API App')
param appServicePlanId string

param containerRegistryName string

@secure()
param dockerRegistryServerUserName string

@secure()
param dockerRegistryServerPassword string

param dockerRegistryImageName string

param dockerRegistryImageTag string

param appCommandLine string = ''

var dockerAppSettings = [
  { name: 'DOCKER_REGISTRY_SERVER_URL', value: 'https://${containerRegistryName}.azurecr.io' }
  { name: 'DOCKER_REGISTRY_SERVER_USERNAME', value: dockerRegistryServerUserName }
  { name: 'DOCKER_REGISTRY_SERVER_PASSWORD', value: dockerRegistryServerPassword }
  { name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE', value: 'true' } // Allows docker container to have access to env variables
]

resource appServiceAPIApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAPIAppName
  location: location
  identity: { type: 'SystemAssigned' }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${dockerRegistryImageName}:${dockerRegistryImageTag}'
      alwaysOn: false
      ftpsState: 'FtpsOnly'
      appCommandLine: appCommandLine
      appSettings: dockerAppSettings
    }
  }
}

output backendAppHostName string = appServiceAPIApp.properties.defaultHostName
output systemAssignedIdentityPrincipalId string = appServiceAPIApp.identity.principalId
