@description('The location for all resources')
param location string
@description('The name of the Container Registry')
param acrName string
@description('The name of the App Service Plan')
param appServicePlanName string
@description('The name of the Web App')
param webAppName string
@description('The name of the container image')
param containerRegistryImageName string
@description('The version/tag of the container image')
param containerRegistryImageVersion string
@description('The key vault name')
param keyVaultName string
@description('Role assignments for the Key Vault')
param keyVaultRoleAssignments array = []

// ACR deployment
module acr 'modules/acr.bicep' = {
  name: 'acrDeployment'
  params: {
    name: acrName
    location: location
    acrAdminUserEnabled: true
  }
}

// Initial Key Vault deployment
module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    roleAssignments: keyVaultRoleAssignments
    location: location
    keyVaultName: keyVaultName
  }
}

// Reference the deployed Key Vault
resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
  dependsOn: [
    keyVault
  ]
}

// Add Key Vault secrets for ACR credentials
resource acrPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVaultReference
  name: 'acr-password'
  properties: {
    value: acr.outputs.adminPassword
  }
}

resource acrUsernameSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVaultReference
  name: 'acr-username'
  properties: {
    value: acr.outputs.adminUsername
  }
}

// App Service Plan deployment
module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlanDeployment'
  params: {
    name: appServicePlanName
    location: location
    kind: 'Linux'
    reserved: true
  }
}

// Web App deployment
module webApp 'modules/web-app.bicep' = {
  name: 'webAppDeployment'
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: appServicePlan.outputs.id
    identity: {
      type: 'SystemAssigned'
    }
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acr.outputs.loginServer}/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
      DOCKER_REGISTRY_SERVER_URL: 'https://${acr.outputs.loginServer}'
      DOCKER_REGISTRY_SERVER_USERNAME: '@Microsoft.KeyVault(SecretUri=${keyVault.outputs.keyVaultUri}/secrets/acr-username/)'
      DOCKER_REGISTRY_SERVER_PASSWORD: '@Microsoft.KeyVault(SecretUri=${keyVault.outputs.keyVaultUri}/secrets/acr-password/)'
    }
  }
  dependsOn: [
    acr
    appServicePlan
    acrPasswordSecret
    acrUsernameSecret
  ]
}

// Add RBAC role assignment for web app to access Key Vault secrets
resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVaultReference.id, webApp.name, 'Key Vault Secrets User')
  scope: keyVaultReference
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
    principalId: webApp.outputs.principalId
    principalType: 'ServicePrincipal'
  }
}
