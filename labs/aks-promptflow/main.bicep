
@description('The prefix name of the Managed Cluster resource.')
param aksPrefixName string

@description('The location of the Managed Cluster resource.')
param aksLocation string = resourceGroup().location

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(100)
param nodePoolCount int = 1

@description('The size of the Virtual Machine for the node pool.')
param nodePoolVMSize string = 'standard_d2s_v3'

@description('The prefix name of the ACR resource.')
param acrPrefixName string

@description('The location of the ACR resource.')
param acrLocation string = resourceGroup().location

@description('The prefix name of the OpenAI resource.')
param openAIPrefixName string

@description('The prefix name of the OpenAI resource.')
param openAILocation string = resourceGroup().location

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

@description('Name of the Log Analytics resource')
param logAnalyticsPrefixName string = 'workspace'

@description('Location of the Log Analytics resource')
param logAnalyticsLocation string = resourceGroup().location

@description('Name of the Application Insights resource')
param applicationInsightsPrefixName string = 'insights'

@description('Location of the Application Insights resource')
param applicationInsightsLocation string = resourceGroup().location

@description('The AI Studio Hub Resource name')
param aiStudioHubPrefixName string
@description('The AI Studio Hub Resource location')
param aiStudioHubLocation string = resourceGroup().location

@description('The SKU name to use for the AI Studio Hub Resource')
param aiStudioSKUName string = 'Basic'
@description('The SKU tier to use for the AI Studio Hub Resource')
@allowed(['Basic', 'Free', 'Premium', 'Standard'])
param aiStudioSKUTier string = 'Basic'
@description('The name of the AI Studio Hub Project')
param aiStudioProjectName string

@description('The storage account ID to use for the AI Studio Hub Resource')
param storageAccountPrefixName string = 'storage'
@description('The storage account location')
param storageAccountLocation string = resourceGroup().location

@description('The key vault ID to use for the AI Studio Hub Resource')
param keyVaultPrefixName string = 'akv'
@description('The key vault location')
param keyVaultLocation string = resourceGroup().location


var resourceSuffix = uniqueString(subscription().id, resourceGroup().id)

resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: '${aksPrefixName}${resourceSuffix}'
  location: aksLocation
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

resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: '${acrPrefixName}${resourceSuffix}'
  location: acrLocation
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: true
    anonymousPullEnabled: false
    dataEndpointEnabled: false
    encryption: {
      status: 'disabled'
    }
    networkRuleBypassOptions: 'AzureServices'
    policies:{
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
      exportPolicy: {
        status: 'enabled'
      }
      azureADAuthenticationAsArmPolicy: {
        status: 'enabled'
      }
      softDeletePolicy: {
        retentionDays: 7
        status: 'disabled'
      }
    }
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Disabled'
  }  
}
@description('This is the built-in role to Pull artifacts from a container registry. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull')
resource acrPullDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: resourceGroup()
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
}

resource aksAcrPermissions 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id)
  scope: acr
  properties: {
    description: 'Allows AKS to pull container images from this ACR instance.'
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    roleDefinitionId: acrPullDefinition.id
    principalType: 'ServicePrincipal'
  }
}


resource openAIResource 'Microsoft.CognitiveServices/accounts@2021-10-01' = {
  name: '${openAIPrefixName}-${resourceSuffix}'
  location: openAILocation
  sku: {
    name: openAISku
  }
  kind: 'OpenAI'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
    customSubDomainName: toLower('${openAIPrefixName}-${resourceSuffix}')
  }
}

resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01'  =  {
    name: openAIDeploymentName
    parent: openAIResource
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

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${logAnalyticsPrefixName}-${resourceSuffix}'
  location: logAnalyticsLocation
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${applicationInsightsPrefixName}-${resourceSuffix}'
  location: applicationInsightsLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

output applicationInsightsAppId string = applicationInsights.properties.AppId

output logAnalyticsWorkspaceId string = logAnalytics.properties.customerId


resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: '${keyVaultPrefixName}-${resourceSuffix}'
  location: keyVaultLocation
  properties: {
    tenantId: subscription().tenantId
    sku: { family: 'A', name: 'standard' }
    accessPolicies: []
  }
}

resource keyVaultAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [ {
        objectId: hub.identity.principalId
        tenantId: subscription().tenantId
        permissions: { secrets: [ 'get', 'list' ] }
      } ]
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
    name: '${storageAccountPrefixName}${resourceSuffix}'
    location: storageAccountLocation
    kind: 'StorageV2'
    sku: { name: 'Standard_LRS' }
    properties: {
      accessTier: 'Hot'
      allowBlobPublicAccess: true
      allowCrossTenantReplication: true
      allowSharedKeyAccess: true
      defaultToOAuthAuthentication: false
      dnsEndpointType: 'Standard'
      minimumTlsVersion: 'TLS1_2'
      networkAcls: {
        bypass: 'AzureServices'
        defaultAction: 'Allow'
      }
      publicNetworkAccess: 'Enabled'
      supportsHttpsTrafficOnly: true
  }

  resource blobServices 'blobServices' = {
    name: 'default'
    properties: {
      cors: {
        corsRules: [
          {
            allowedOrigins: [
              'https://mlworkspace.azure.ai'
              'https://ml.azure.com'
              'https://*.ml.azure.com'
              'https://ai.azure.com'
              'https://*.ai.azure.com'
              'https://mlworkspacecanary.azure.ai'
              'https://mlworkspace.azureml-test.net'
            ]
            allowedMethods: [
              'GET'
              'HEAD'
              'POST'
              'PUT'
              'DELETE'
              'OPTIONS'
              'PATCH'
            ]
            maxAgeInSeconds: 1800
            exposedHeaders: [
              '*'
            ]
            allowedHeaders: [
              '*'
            ]
          }
        ]
      }
      deleteRetentionPolicy: {
        allowPermanentDelete: false
        enabled: false
      }
    }
    resource container 'containers' = {
      name: 'default'
      properties: {
        publicAccess: 'None'
      }
    }
  }

  resource fileServices 'fileServices' = {
    name: 'default'
    properties: {
      cors: {
        corsRules: [
          {
            allowedOrigins: [
              'https://mlworkspace.azure.ai'
              'https://ml.azure.com'
              'https://*.ml.azure.com'
              'https://ai.azure.com'
              'https://*.ai.azure.com'
              'https://mlworkspacecanary.azure.ai'
              'https://mlworkspace.azureml-test.net'
            ]
            allowedMethods: [
              'GET'
              'HEAD'
              'POST'
              'PUT'
              'DELETE'
              'OPTIONS'
              'PATCH'
            ]
            maxAgeInSeconds: 1800
            exposedHeaders: [
              '*'
            ]
            allowedHeaders: [
              '*'
            ]
          }
        ]
      }
      shareDeleteRetentionPolicy: {
        enabled: true
        days: 7
      }
    }
  }

  resource queueServices 'queueServices' = {
    name: 'default'
    properties: {

    }
    resource queue 'queues' = {
      name: 'default'
      properties: {
        metadata: {}
      }
    }
  }

  resource tableServices 'tableServices' = {
    name: 'default'
    properties: {}
  }
}

resource hub 'Microsoft.MachineLearningServices/workspaces@2024-01-01-preview' = {
  name: '${aiStudioHubPrefixName}-${resourceSuffix}'
  location: aiStudioHubLocation
  sku: {
    name: aiStudioSKUName
    tier: aiStudioSKUTier
  }
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: aiStudioHubPrefixName
    storageAccount: storage.id
    keyVault: keyVault.id
    applicationInsights: applicationInsights.id
    containerRegistry: acr.id
    hbiWorkspace: false
    managedNetwork: {
      isolationMode: 'Disabled'
    }
    v1LegacyMode: false
    publicNetworkAccess: 'Enabled'
    discoveryUrl: 'https://${aiStudioHubLocation}.api.azureml.ms/discovery'
  }

  resource openAiConnection 'connections@2024-04-01-preview' = {
    name: 'open_ai_connection'
    properties: {
      category: 'AzureOpenAI'
      authType: 'ApiKey'
      isSharedToAll: true
      target: openAIResource.properties.endpoint
      metadata: {
        ApiVersion: '2024-02-01'
        ApiType: 'azure'
      }
      credentials: {
        key: openAIResource.listKeys().key1
      }
    }
  }
}

resource project 'Microsoft.MachineLearningServices/workspaces@2024-01-01-preview' = {
  name: '${aiStudioProjectName}-${resourceSuffix}'
  location: aiStudioHubLocation
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  kind: 'Project'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: aiStudioProjectName
    hbiWorkspace: false
    v1LegacyMode: false
    publicNetworkAccess: 'Enabled'
    discoveryUrl: 'https://${aiStudioHubLocation}.api.azureml.ms/discovery'
    hubResourceId: hub.id
  }
}


output aksResourceName string = aks.name
output acrResourceName string = acr.name
output openAIResourceName string = openAIResource.name
output openAIEndpoint string = openAIResource.properties.endpoint

#disable-next-line outputs-should-not-contain-secrets
output openAIKey string = openAIResource.listKeys().key1

output projectName string = project.name
output projectId string = project.id



