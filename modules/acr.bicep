#disable-next-line secure-secrets-in-params
@description('The name of the container registry')
param name string

@description('The location of the container registry')
param location string

@description('Enable admin user for the container registry')
param acrAdminUserEnabled bool

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

// Outputs needed by the web app
output loginServer string = acr.properties.loginServer
#disable-next-line outputs-should-not-contain-secrets
output adminUsername string = acrAdminUserEnabled ? acr.listCredentials().username : ''
#disable-next-line outputs-should-not-contain-secrets
output adminPassword string = acrAdminUserEnabled ? acr.listCredentials().passwords[0].value : ''
