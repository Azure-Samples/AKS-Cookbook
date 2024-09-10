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

@description('principalId of the user that will be given contributor access to the cluster')
param userPrincipalId string

@description('roleDefinition to apply to the resourceGroup - default is contributor')
param roleDefinitionId string

// MARK: AKS resource
resource aks 'Microsoft.ContainerService/managedClusters@2024-03-02-preview' = {
  name: clusterName
  location: clusterLocation
  sku: {
    name: 'Automatic'
    tier: 'Standard'
  }
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

// MARK: role assignment
var roleAssignmentName= guid(userPrincipalId, roleDefinitionId, resourceGroup().id)
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  scope: aks
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: userPrincipalId
  }
}

// MARK: outputs
output aksResourceId string = aks.id
output controlPlaneFQDN string = aks.properties.fqdn
