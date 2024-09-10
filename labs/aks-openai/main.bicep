var resourceSuffix = uniqueString(subscription().id, resourceGroup().id)

// MARK: AKS params
@description('The name of the Managed Cluster resource.')
param clusterName string

@description('The location of the Managed Cluster resource.')
param clusterLocation string = resourceGroup().location

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(100)
param nodePoolCount int = 1

@description('The size of the Virtual Machine for the node pool.')
param nodePoolVMSize string = 'standard_d2s_v3'

// OpenAI params
@description('OpenAI resource prefix')
param openAIResourcePrefix string = 'openai'

@description('OpenAI resource location')
param openAIResourceLocation string = resourceGroup().location

@description('Deployment Name')
param openAIDeploymentName string

@description('Azure OpenAI Sku')
@allowed([
  'S0'
])
param openAISku string = 'S0'

@description('Model Name')
param openAIModelName string

@description('Model Version')
param openAIModelVersion string

@description('Model Capacity')
param openAIModelCapacity int = 20

// MARK: AKS resource
resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: clusterLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: resourceSuffix
    agentPoolProfiles: [
      {
        name: 'nodepool'
        count: nodePoolCount
        vmSize: nodePoolVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
  }
}

// MARK: OpenAI
resource cognitiveServices 'Microsoft.CognitiveServices/accounts@2021-10-01' = {
  name: '${openAIResourcePrefix}-${resourceSuffix}'
  location: openAIResourceLocation
  sku: {
    name: openAISku
  }
  kind: 'OpenAI'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
    customSubDomainName: toLower('${openAIResourcePrefix}-${resourceSuffix}')
  }
}

resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
    name: openAIDeploymentName
    parent: cognitiveServices
    properties: {
      model: {
        format: 'OpenAI'
        name: openAIModelName
        version: openAIModelVersion
      }
    }
    sku: {
        name: 'Standard'
        capacity: openAIModelCapacity
    }
}

// MARK: deployment

module kubernetes './aks-store-quickstart.bicep' = {
  name: 'buildbicep-deploy'
  params: {
    kubeConfig: aks.listClusterAdminCredential().kubeconfigs[0].value
    deploymentName: deployment.name
    openAIEndpoint: cognitiveServices.properties.endpoint
    openAIKey: cognitiveServices.listKeys().key1
  }
}


// MARK: outputs
output controlPlaneFQDN string = aks.properties.fqdn
