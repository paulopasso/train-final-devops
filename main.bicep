// Parameters
@description('The location for all resources')
param location string

@description('The name of the Container Registry')
param acrName string

@description('The name of the App Service Plan')
param appServicePlanName string

@description('The API App name (backend)')
param webAppName string

@description('The name of the container image')
param containerRegistryImageName string

@description('The version/tag of the container image')
param containerRegistryImageVersion string

@description('The key vault name')
param keyVaultName string

@description('Role assignments for Key Vault')
param keyVaultRoleAssignments array = []

// Key Vault deployment
module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    keyVaultName: keyVaultName
    location: location
    roleAssignments: keyVaultRoleAssignments
  }
}

// Reference the deployed Key Vault
resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
  dependsOn: [
    keyVault
  ]
}

// ACR deployment
module acr 'modules/acr.bicep' = {
  name: 'acrDeployment'
  params: {
    name: acrName
    location: location
    keyVaultResourceId: keyVault.outputs.keyVaultResourceId
    keyVaultSecretNameAdminUsername: 'acr-username'
    keyVaultSecretNameAdminPassword0: 'acr-password0'
    keyVaultSecretNameAdminPassword1: 'acr-password1'
  }
  dependsOn: [
    keyVault
  ]
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
    appServiceAPIAppName: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    containerRegistryName: acrName
    dockerRegistryServerUserName: keyVaultReference.getSecret('acr-username')
    dockerRegistryServerPassword: keyVaultReference.getSecret('acr-password0')
    dockerRegistryImageName: containerRegistryImageName
    dockerRegistryImageTag: containerRegistryImageVersion
  }
  dependsOn: [
    acr
    appServicePlan
  ]
}

// Outputs
output webAppHostName string = webApp.outputs.backendAppHostName
output keyVaultResourceId string = keyVault.outputs.keyVaultResourceId
