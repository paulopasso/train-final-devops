# Deploy a Python (Flask) web app to Azure App Service - Sample Application

This project demonstrates how to deploy a containerized Python Flask application to Azure using Infrastructure as Code (IaC) with Bicep and GitHub Actions for CI/CD.

## Infrastructure Components

The solution consists of three main Azure resources:

1. **Azure Key Vault** - Securely stores credentials
2. **Azure Container Registry (ACR)** - Hosts the application container images
3. **Azure Web App** - Runs the containerized application

## Project Structure

```
├── .github/workflows/
│   └── workflow.yaml        # GitHub Actions CI/CD pipeline
├── modules/
│   ├── key-vault.bicep      # Key Vault infrastructure
│   ├── container-registry.bicep  # ACR infrastructure
│   └── web-app.bicep        # Web App infrastructure
├── main.bicep              # Main infrastructure template
├── main.parameters.json    # Infrastructure parameters
└── Dockerfile             # Container image definition
```

## Getting Started

### 1. Customize Parameters

Before deploying, modify `main.parameters.json` to replace existing names with your own:

- Replace all instances of `dkumlin` with your identifier
- Example changes:
  ```json
  {
    "keyVaultName": { "value": "yourname-kv" },
    "containerRegistryName": { "value": "yournamecr" },
    "webAppName": { "value": "yourname-webapp" }
  }
  ```

### 2. Update GitHub Workflow

Modify `.github/workflows/workflow.yaml` environment variables:

```yaml
env:
  KEY_VAULT_NAME_DEV: "yourname-kv"
  CONTAINER_REGISTRY_SERVER_URL_DEV: "yournamecr.azurecr.io"
  IMAGE_NAME_DEV: "yourname-app"
  WEB_APP: "yourname-webapp"
```

### 3. Configure GitHub Secrets

Set up required GitHub repository secrets:

- `AZURE_CREDENTIALS`: Service principal credentials
- `AZURE_SUBSCRIPTION`: Subscription ID (For the resource subsciption)

## How the Infrastructure Works

### Deployment Flow

1. **Infrastructure Deployment**

   - Bicep templates create/update Azure resources
   - RBAC permissions are configured automatically
   - Resources are created in the specified order:
     1. Key Vault
     2. Container Registry
     3. Web App

2. **Application Deployment**
   - GitHub Actions workflow:
     1. Builds container image
     2. Retrieves ACR credentials from Key Vault
     3. Pushes image to ACR
     4. Deploys to Web App

### Customizing the Infrastructure

#### Modify Key Vault (modules/key-vault.bicep)

- Change SKU tier
- Add/modify role assignments
- Adjust network access rules

```bicep
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  properties: {
    sku: {
      family: 'A'
      name: 'standard'  // Change to 'premium' if needed
    }
    // Add network rules here
  }
}
```

#### Customize Container Registry (modules/container-registry.bicep)

- Change SKU
- Enable/disable features
- Configure geo-replication

```bicep
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  sku: {
    name: 'Basic'  // Change to 'Standard' or 'Premium'
  }
}
```

#### Modify Web App (modules/web-app.bicep)

- Change pricing tier
- Adjust app settings
- Configure scaling

```bicep
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  properties: {
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerImage}'
      // Add custom app settings
      appSettings: []
    }
  }
}
```

## Troubleshooting

Common issues and solutions:

1. **Deployment Failures**

   - Check resource name uniqueness
   - Verify service principal permissions
   - Review deployment logs in Azure Portal

2. **Container Issues**

   - Verify ACR credentials in Key Vault
   - Check container logs in Web App
   - Ensure container image exists in ACR

3. **Access Issues**
   - Check RBAC role assignments
   - Verify service principal hasn't expired
   - Confirm Key Vault access policies

## Prerequisites

- Azure Subscription
- GitHub Account
- Azure CLI (for local testing)
- Docker (for local testing)
