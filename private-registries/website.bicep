/* You've created a private registry for your toy company to use. In this exercise, you will:
New-AzContainerRegistry -Name dvl69420 -Sku Basic -Location westus
Get-AzContainerRegistryRepository -RegistryName dvl69420
Create a module for the website resources.
Create another module for the resources in the CDN.
Publish the modules to your registry.
List the modules in the registry.*/

@description('The Azure region into which the resources should be deployed.')
param location string

@description('The name of the App Service app.')
param appServiceAppName string

@description('The name of the App Service plan.')
param appServicePlanName string

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2023-12-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

@description('The default host name of the App Service app.')
output appServiceAppHostName string = appServiceApp.properties.defaultHostName
