@description('The location into which your Azure resources should be deployed')
param location string = resourceGroup().location

@description('Select the type of environment you want to provision. Allowed values are Production and Test.')
@allowed([
  'Production'
  'Test'
])
param environmentType string

@description('A unique suffix to add to resource names that need to be globally unique.')
@maxLength(13)
param resourceNameSuffix string = uniqueString(resourceGroup().id)

@description('The administrator login username for the SQL server')
param sqlServerAdministratorLogin  string

@description('The administrator login password for the SQL server')
@secure()
param sqlServerAdministratorLoginPassword string

@description('The tags to apply to each resource')
param tags object = {
  CostCenter: 'Marketing'
  DataClassification: 'Public'
  Owner: 'Website team'
  Environment: 'Production'
}

//Name variables for the resources
var appServiceAppName = 'website${resourceNameSuffix}'
var appServicePlanName = 'AppServicePlan'
var sqlServerName = 'sqlserver${resourceNameSuffix}'
var sqlDatabaseName = 'ToyCompanyWebsite'
var managedIdentityName = 'Website'
var applicationInsightsName = 'AppInsights'
var storageAccountName = 'toywebsite${resourceNameSuffix}'
var blobContainersName = [
  'productspecs'
  'productmanuals'
]

@description('Define the SKUs for each component based on the environment type')
var environmentConfigurationMap = {
  Production: {
    appServicePlan: {
      sku: {
        name: 'S1'
        capacity: 2
      }
    }
    storageAccount: {
      sku: {
        name: 'Standard_GRS'
      }
    }
    sqlDatabase: {
      sku: {
        name: 'S1'
        tier: 'Standard'
      }
    }
  }
  Test: {
    appServicePlan: {
      sku: {
        name: 'F1'
        capacity: 1
      }
    }
    storageAccount: {
      sku: {
        name: 'Standard_LRS'
      }
    }
    sqlDatabase: {
      sku: {
        name: 'Basic'
      }
    }
  }
}

@description('The role definition id of the built-in Azure \'Contributor\' role.')
var contributorRoleDefinitionId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin 
    administratorLoginPassword: sqlServerAdministratorLoginPassword
    version: '12.0'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: environmentConfigurationMap[environmentType].sqlDatabase.sku
}

resource sqlserverName_AllowAllAzureIPs 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
  parent: sqlServer
  name: 'AllowAllAzureIPs'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: 'eastus'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }

  resource blobServices 'blobServices' existing = {
    name: 'default'
  }
}

resource container1 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: storageAccount::blobServices
  name: container1Name
}

resource productmanuals 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  name: '${storageAccount.name}/default/${productmanualsName}'
}
resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
  }
}

resource webSite 'Microsoft.Web/sites@2023-12-01' = {
  name: webSiteName
  location: location
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: AppInsights_webSiteName.properties.InstrumentationKey
        }
        {
          name: 'StorageAccountConnectionString'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
      ]
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${msi.id}': {}
    }
  }
}

resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: managedIdentityName
  location: location
}

resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(roleDefinitionId, resourceGroup().id)

  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: msi.properties.principalId
  }
}

resource AppInsights_webSiteName 'Microsoft.Insights/components@2020-02-02' = {
  name: 'AppInsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}
