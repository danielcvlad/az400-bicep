@description('The Azure region into which the resources should be deployed.')
param location string = 'westus3'

@description('The name of the App Service app.')
param appServiceAppName string = 'toy-${uniqueString(resourceGroup().id)}'

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string = 'F1'

var appServicePlanName = 'toy-dog-plan'

module website 'br:dvl69420.azurecr.io/website:v1' = {
  name: 'toy-dog-website'
  params: {
    appServiceAppName: appServiceAppName
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    location: location
  }
}

module cdn 'br:dvl69420.azurecr.io/cdn:v1' = {
  name: 'toy-dog-cdn'
  params: {
    httpsOnly: true
    originHostName: website.outputs.appServiceAppHostName
  }
}
