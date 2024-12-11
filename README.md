# Python Flask Web Application Deployment to Azure

This project demonstrates how to containerize a Python Flask application and deploy it to Azure using Infrastructure as Code (Bicep) and GitHub Actions.

## Development Process Steps

### 1. Container Development and Local Testing

First, I developed and tested the application locally:

```bash
# Build the container
docker build -t myapp .

# Run and test locally
docker run -p 5000:5000 myapp

# Test in browser: http://localhost:5000
```

### 2. Infrastructure Development

After confirming the container works, I built the infrastructure in steps:

1. Created `main.bicep` with basic resource structure:

   - Key Vault
   - Container Registry
   - Web App

2. Developed individual module files in `/modules`:
   - `key-vault.bicep`: Stores ACR credentials securely
   - `container-registry.bicep`: Hosts our container images
   - `web-app.bicep`: Runs our containerized application

### 3. GitHub Actions Workflow

Created `.github/workflows/workflow.yaml` with three main stages:

1. **Infrastructure Deployment Stage**

   - Deploys all Bicep templates
   - Creates/updates Azure resources
   - Sets up RBAC permissions

2. **Run Tests Stage**

   - Builds the Docker image
   - Runs tests on the container
   - Exits with error if tests fail

3. **Container Build & Push Stage**

   - Builds the Docker image
   - Tags with git SHA
   - Pushes to Azure Container Registry

4. **Web App Deployment Stage**
   - Pulls latest image from ACR
   - Deploys to Azure Web App
   - Updates container configuration

## How to Use This Project

### Prerequisites

- Azure Subscription
- GitHub Account
- Docker Desktop
- Azure CLI

### Deployment Steps

1. **Fork/Clone the Repository**

2. **Update Parameters**
   Replace all instances of `yourname` with your identifier in:

   ```json
   // main.parameters.json
   {
     "keyVaultName": { "value": "yourname-kv" },
     "containerRegistryName": { "value": "yourname-cr" },
     "webAppName": { "value": "yourname-webapp" }
   }
   ```

3. **Configure GitHub Secrets**
   Add to your repository:

   - `AZURE_CREDENTIALS`
   - `AZURE_SUBSCRIPTION`

4. **Update Workflow Variables**
   In `.github/workflows/workflow.yaml`:

   ```yaml
   env:
     KEY_VAULT_NAME_DEV: "yourname-kv"
     CONTAINER_REGISTRY_SERVER_URL_DEV: "yournamecr.azurecr.io"
     IMAGE_NAME_DEV: "yourname-app"
     WEB_APP: "yourname-webapp"
   ```

5. **Deploy**
   - Push to main branch
   - GitHub Actions will handle the deployment

## Project Structure

```
├── .github/workflows/
│   └── workflow.yaml        # CI/CD pipeline
├── modules/
│   ├── key-vault.bicep      # Key Vault infrastructure
│   ├── container-registry.bicep  # ACR infrastructure
│   └── web-app.bicep        # Web App infrastructure
├── main.bicep              # Main infrastructure template
├── main.parameters.json    # Infrastructure parameters
└── Dockerfile             # Container image definition
```

## Troubleshooting

### Common Issues

1. **Resource Name Conflicts**

   - Ensure all resource names are unique
   - Update parameters with your unique identifiers

2. **Container Registry Access**

   - Verify Key Vault contains correct ACR credentials
   - Check service principal has proper permissions

3. **Web App Deployment**
   - Check container logs in Azure Portal
   - Verify container image exists in ACR
   - Confirm Web App configuration matches container

### Useful Commands

```bash
# Check container locally
docker build -t myapp .
docker run -p 5000:5000 myapp

```
